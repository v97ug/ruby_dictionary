#! /usr/bin/ruby

require 'uri'
require 'open-uri'
require 'nokogiri'
require 'readline'
require 'pry'

def get_item_id(url)
  xml = open(url).read
  doc = Nokogiri::XML(xml)
  item_id = doc.search('ItemID').first.inner_text rescue nil
  item_id
end

def get_en_translation(url)
  xml = open(url).read
  doc = Nokogiri::XML(xml)
  doc.css('.NetDicBody').children[1].inner_html.gsub("\t","\n") rescue nil
end

def translate_en_to_jp(word_en)
  # (1) 英単語の単語ItemIdを取得
  enc_word = URI.encode(word_en)
  item_url = "http://public.dejizo.jp/NetDicV09.asmx/SearchDicItemLite?Dic=EJdict&Word=#{enc_word}&Scope=HEADWORD&Match=EXACT&Merge=OR&Prof=XHTML&PageSize=20&PageIndex=0"
  item_id = get_item_id(item_url)
  trans_url = "http://public.dejizo.jp/NetDicV09.asmx/GetDicItemLite?Dic=EJdict&Item=#{item_id}&Loc=&Prof=XHTML"
  get_en_translation(trans_url)
end

def get_jp_translation(url)
  xml = open(url).read
  doc = Nokogiri::XML(xml.strip.gsub(/(\r\n|\r|\n|\f|\t)/,""))
  doc.css('.NetDicBody').children[0].children.map{|a| a.text.strip}.reject{|a| a == ''}.join("\n") rescue nil
end

def translate_jp_to_en(word_jp)
  # 日本語単語のItemIdを取得
  enc_word = URI.encode(word_jp)
  item_url = "http://public.dejizo.jp/NetDicV09.asmx/SearchDicItemLite?Dic=EdictJE&Word=#{enc_word}&Scope=HEADWORD&Match=EXACT&Merge=OR&Prof=XHTML&PageSize=20&PageIndex=0"
  item_id = get_item_id(item_url)
  trans_url = "http://public.dejizo.jp/NetDicV09.asmx/GetDicItemLite?Dic=EdictJE&Item=#{item_id}&Loc=&Prof=XHTML"
  get_jp_translation(trans_url)
end

puts "0: English to Japanese, 1: Japanese to English"
en_or_jp = Readline.readline("> ", true)
if en_or_jp == "0"
  puts "English to Japanese mode!"
  puts "finish when pressed Ctrl-D"
  while (buf = Readline.readline("> ", true))
    if buf == ""
      next
    end
    meaning = translate_en_to_jp(buf) || '(・３・)< no hit >'
    puts meaning
  end
else
  puts "Japanese to English mode!"
  puts "finish when pressed Ctrl-D"
  while (buf = Readline.readline("> ", true))
    if buf == ""
      next
    end
    meaning = translate_jp_to_en(buf) || '(・３・)< no hit >'
    puts meaning
  end
end

puts "Thank you!(*^^*)"