# encoding: utf-8
class Cms::Feed < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  belongs_to :status,         :foreign_key => :state,           :class_name => 'Sys::Base::Status'
  has_many   :entries,        :foreign_key => :feed_id,         :class_name => 'Cms::FeedEntry',
    :dependent => :destroy

  validates_presence_of :name, :uri, :title

  def public
    self.and "#{self.class.table_name}.state", 'public'
    self
  end

  def ass(alt = nil, &block)
    begin
      yield
    rescue NoMethodError => e
      if e.respond_to? :args and (e.args.nil? or (!e.args.blank? and e.args.first.nil?))
        alt
      end
    end
  end

  def request_feed
     res = Util::Http::Request.send(uri)
    if res.status != 200
      errors.add_to_base "RequestError: #{uri}"
      return nil
    end
    return res.body
  end


  def update_feed
    unless xml = request_feed
      errors.add_to_base "FeedRequestError: #{uri}"
      return false
    end

    require "rexml/document"
    doc  = REXML::Document.new(xml)
    root = doc.root

    ## feed
    self.feed_id      = root.elements['id'].text
    self.feed_type    = nil
    self.feed_updated = root.elements['updated'].text
    self.feed_title   = root.elements['title'].text
    root.each_element('link') do |l|
      self.link_alternate = l.attribute('href').to_s if l.attribute('rel').to_s == 'alternate'
    end
    self.entry_count ||= 20
    save

    ## entries
    begin
      #require 'parsedate'
      require 'date/format'
      latest = []

      root.get_elements('entry').each_with_index do |e, i|
        break if i >= self.entry_count

        entry_id      = e.elements['id'].text
        entry_updated = e.elements['updated'].text

        cond  = {:feed_id => self.id, :entry_id => entry_id}
        if entry = Cms::FeedEntry.find(:first, :conditions => cond)
          #arr = ParseDate::parsedate(entry_updated)
          arr = Date._parse(entry_updated, false).values_at(:year, :mon, :mday, :hour, :min, :sec, :zone, :wday)

          new = Time::local(*arr[0..-3]).strftime('%s').to_i
          old = entry.entry_updated.strftime('%s').to_i
          if new <= old
            latest << entry.id
            next
          end
        else
          entry = Cms::FeedEntry.new
        end

        ## base
        entry.content_id       = self.content_id
        entry.feed_id          = self.id
        entry.state          ||= 'public'
        entry.entry_id         = entry_id
        entry.entry_updated    = entry_updated
        entry.title            = ass{e.elements['title'].text}
        entry.summary          = ass{e.elements['summary'].text}

        ## links
        e.each_element('link') do |l|
          entry.link_alternate = l.attribute('href').to_s if l.attribute('rel').to_s == 'alternate'
          entry.link_enclosure = l.attribute('href').to_s if l.attribute('rel').to_s == 'enclosure'
        end

        ## categories, event_date
        categories = []
        event_date = nil
        e.each_element('category') do |c|
          cate_label = c.attribute('label').to_s.gsub(/ /, '_')

          if c.attribute('term').to_s == 'event'
            _year, _month, _day = /(^|\n)イベント\/([0-9]{4})-([0-9]{2})-([0-9]{2})T/.match(cate_label).to_a.values_at(2, 3, 4)
            if _year && _month && _day
              begin
                event_date = Date.new(_year.to_i, _month.to_i, _day.to_i)
              rescue
              end
            end
          end
          categories << cate_label
        end
        entry.categories = categories.join("\n")
        entry.event_date = event_date

        ## author
        if author = e.elements['author']
          entry.author_name    = ass{author.elements['name'].text}
          entry.author_email   = ass{author.elements['email'].text}
          entry.author_uri     = ass{author.elements['uri'].text}
        end

        if entry.save
          latest << entry.id
        end
      end
    rescue Exception => e
      errors.add_to_base "FeedEntryError: #{e}"
    end

    if latest.size > 0
      cond = Condition.new
      cond.and "NOT id", "IN", latest
      cond.and :feed_id, self.id
      Cms::FeedEntry.destroy_all(cond.where)
    end
    return errors.size == 0

  rescue => e
    errors.add_to_base "Error: #{e.class}"
    return false
  end
end