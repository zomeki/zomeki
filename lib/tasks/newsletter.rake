require 'csv'

namespace :zomeki do
  namespace :newsletter do
    desc 'Import newsletter members from csv.'
    task(:import_newsletter_members => :environment) do
      i_n_m('newsletter_members.csv', 'newsletter')
    end
  end
end

def i_n_m(csv_file, content_code)
  content = Newsletter::Content::Base.find_by_code(content_code)
  raise %Q(Content not found with code "#{content_code}".) unless content

  csv = File.read(Rails.root.join('tmp', csv_file))
  csv = csv.encode(Encoding::UTF_8, Encoding::WINDOWS_31J,
                   :invalid => :replace, :undef => :replace,
                   :universal_newline => true)

  rows = CSV.parse(csv)
  rows.shift # Discard headers
  rows.each do |row|
    letter_type = case row[1]
                  when 'PC版';   'pc_text'
                  when '携帯版'; 'mobile_text'
                  end
    next unless letter_type

    while m = Newsletter::Member.find_by_content_id_and_letter_type_and_email(content.id, letter_type, row[0])
      m.destroy
    end

    Newsletter::Member.create(
      state: 'enabled',
      content_id: content.id,
      letter_type: letter_type,
      email: row[0]
    )
  end
end
