require 'open-uri'
require 'nokogiri'
require 'mechanize'

namespace :hotpepper do

  desc "Generate hotpepper data"
  task :generate => :environment do
    url_list = [ 
      'https://www.hotpepper.jp/gstr00001/G001/',
      'https://www.hotpepper.jp/gstr00001/G001/bgn2/',
      'https://www.hotpepper.jp/gstr00001/G001/bgn3/',
      'https://www.hotpepper.jp/gstr00001/G001/bgn4/',
      'https://www.hotpepper.jp/gstr00001/G001/bgn5/',
      'https://www.hotpepper.jp/gstr00001/G001/bgn6/'
    ] 
    
    url_list.each do |url|

      charset = nil
      html = open(url) do |f|
        charset = f.charset
        f.read
      end

      doc = Nokogiri::HTML.parse(html, nil, charset)

      shop_list = doc.xpath('//*[@id="container"]/div/div[1]/div[4]/ul').css("li")
      shop_list.each do |node|
        # shop name
        shop_name = node.xpath('.//dt').text
        shop_code = node.css('a')[0][:href].delete("/")

        keyword = shop_name + " 会社"

        result = GoogleSearch.new.snipet_scraping(keyword) 
        result.each do | value |
          company_url = value[:url]

          #charset = nil
          #html = open(company_url) do |f|
          #  charset = f.charset # ^[$BJ8;z<oJL$r<hF@^[(B
          #  f.read # html^[$B$rFI$_9~$s$GJQ?t^[(Bhtml^[$B$KEO$9^[(B
          #end

          #doc = Nokogiri::HTML.parse(html, nil, charset)
          #title = doc.css("title").inner_text
          #if /（株）*/ == title then
          #  title.slice!(/（株）*/)
          #elsif /(㈱)*/ == title then
          #  title.slice!(/(㈱)*/)
          #elsif /(株)*/ == title then
          #  title.slice!(/(株)*/)
          #elsif /株式会社*/ == title then
          #  title.slice!(/株式会社*/)
          #else
          #end
          shop = Shop.find_or_initialize_by(shop_code:shop_code)
          if shop.new_record?
            shop.name = shop_name
            shop.shop_code = shop_code
            shop.url = company_url
            shop.status = Status.find(1)
            shop.save!
            print "COMPANY:#{shop_name} URL:#{company_url} save ok!!!!!!!!!"
          end

          break
        end
      end
    end

    p "complete, all done!!!!!!!!!!!!!"
  end
end

class GoogleSearch
  def snipet_scraping(keyword)
    submit_keyword(keyword)
    @agent.page.search('div.g').map do |node|
      title = node.search('a')
      next if title.empty?
      query = URI.decode_www_form(URI(title.attr("href")).query)
      url = query[0][1]

      snipped = node.search('div.s > span.st')
      next if snipped.empty? || snipped.children.empty?
      {
        url: url,
        title: expect_tag(title.children.to_html),
        snipped: expect_tag(snipped.children.to_html)
      }
    end.reject do |list|
      list.nil?
    end
  end 

  private

  def submit_keyword(keyword)
    @agent = Mechanize.new   
    @agent.get('https://www.google.co.jp/')
    @agent.page.form_with(name: 'f') do |form|
      form.q = keyword
    end.submit
  end

  def expect_tag(str)
    str.gsub(/(<b>|<\/b>|<br>|<\/br>|\R)/, '')
  end
end

