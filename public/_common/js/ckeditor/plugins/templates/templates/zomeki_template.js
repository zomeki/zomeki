CKEDITOR.addTemplates('zomeki', {
  imagesPath: CKEDITOR.getUrl(CKEDITOR.plugins.getPath('templates') + 'templates/images/'),
  templates: [
    {
      title: '左画像+右テキスト',
      image: 'zomeki_temp1.gif',
      description: '画像の右にテキストを回り込ませるテンプレートです。',
      html: '<div class="temp1 clearfix"><div class="thumb"><img src="/_common/js/ckeditor/plugins/templates/templates/images/sample.gif" alt="画像の説明"></div><p><strong>太字テキスト</strong><br />テキストが回り込みます。<br />サンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプル。</p></div>'
    },
    {
      title: '右画像+左テキスト',
      image: 'zomeki_temp2.gif',
      description: '画像の左にテキストを回り込ませるテンプレートです。',
      html: '<div class="temp2 clearfix"><div class="thumb"><img src="/_common/js/ckeditor/plugins/templates/templates/images/sample.gif" alt="画像の説明"></div><p><strong>太字テキスト</strong><br />テキストが回り込みます。<br />サンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプルサンプル。</p></div>'
    },
    {
      title: '画像2枚横並び',
      image: 'zomeki_temp3.gif',
      description: '画像を2枚並べるテンプレートです。',
      html: '<div class="temp3 clearfix"><dl><dt><img src="/_common/js/ckeditor/plugins/templates/templates/images/sample.gif" alt=""></dt><dd>画像の説明</dd></dl><dl><dt><img src="/_common/js/ckeditor/plugins/templates/templates/images/sample.gif" alt=""></dt><dd>画像の説明</dd></dl></div>'
    },
    {
      title: '画像3枚横並び',
      image: 'zomeki_temp4.gif',
      description: '画像を3枚並べるテンプレートです。',
      html: '<div class="temp4 clearfix"><dl><dt><img src="/_common/js/ckeditor/plugins/templates/templates/images/sample.gif" alt=""></dt><dd>画像の説明</dd></dl><dl><dt><img src="/_common/js/ckeditor/plugins/templates/templates/images/sample.gif" alt=""></dt><dd>画像の説明</dd></dl><dl><dt><img src="/_common/js/ckeditor/plugins/templates/templates/images/sample.gif" alt=""></dt><dd>画像の説明</dd></dl></div>'
    },
    {
      title: '表組み（2列2行 横幅100%）',
      image: 'zomeki_temp5.gif',
      description: '初めの行がデータヘッダ',
      html: '<table class="temp5"><caption>表題を入力</caption><tr><th scope="col">テーブルヘッダ</th><th scope="col">テーブルヘッダ</th></tr><tr><td>テーブルデータ</td><td>テーブルデータ</td></tr></table>'
    },
    {
      title: '表組み（4列4行 横幅指定無し）',
      image: 'zomeki_temp6.gif',
      description: '初めの列と行がデータヘッダ',
      html: '<table class="temp6"><caption>表題を入力</caption><tr><th>&nbsp;</th><th>テーブルヘッダ1</th><th>テーブルヘッダ2</th><th>テーブルヘッダ3</th></tr><tr><th>テーブルヘッダA</th><td>テーブルデータA-1</td><td>テーブルデータA-2</td><td>テーブルデータA-3</td></tr><tr><th>テーブルヘッダB</th><td>テーブルデータB-1</td><td>テーブルデータB-2</td><td>テーブルデータB-3</td></tr><tr><th>テーブルヘッダC</th><td>テーブルデータC-1</td><td>テーブルデータC-2</td><td>テーブルデータC-3</td></tr></table>'
    },
    {
      title: 'Adobe Readerダウンロード',
      image: 'zomeki_temp7.gif',
      description: 'ダウンロードリンクの挿入',
      html: '<div class="temp7"><p>PDFの閲覧にはAdobe System社の無償のソフトウェア「Adobe Reader」が必要です。下記のAdobe Readerダウンロードページから入手してください。</p><a target="_blank" title="Adobe Readerダウンロード" href="http://get.adobe.com/jp/reader/">Adobe Readerダウンロード</a></div>'
    }
  ]}
);
