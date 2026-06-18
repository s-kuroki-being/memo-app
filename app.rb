# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'rack/utils'
require 'securerandom'

enable :method_override

def load_memos
  JSON.parse(File.read('memos.json'))
end

def save_memos(memos)
  File.open('memos.json', 'w') do |f|
    f.write(memos.to_json)
  end
end

helpers do
  def esc(text)
    Rack::Utils.escape_html(text.to_s)
  end
end

# 一覧画面
get '/memos' do
  @title = 'メモアプリ'
  @memos = load_memos
  erb :index
end

# 新規作成画面
get '/memos/new' do
  erb :new
end

# 詳細画面
get '/memos/:id' do
  memos = load_memos
  @memo = memos[params[:id]]
  halt 404, 'Memo not found' if @memo.nil?

  erb :show
end

# 編集画面
get '/memos/:id/edit' do
  memos = load_memos
  @memo = memos[params[:id]]
  halt 404, 'Memo not found' if @memo.nil?

  erb :edit
end

# 新規メモ作成
post '/memos' do
  title = params[:title]&.strip
  content = params[:content]&.strip

  id = SecureRandom.uuid
  memos = load_memos

  memos[id] = { 'id' => id, 'title' => title, 'content' => content }

  save_memos(memos)

  redirect '/memos'
end

# 既存のメモを更新
patch '/memos/:id' do
  memos = load_memos
  memo = memos[params[:id]]
  halt 404, 'Memo not found' if memo.nil?

  title = params[:title]&.strip
  content = params[:content]&.strip

  memo['id'] = params[:id]
  memo['title'] = title
  memo['content'] = content
  save_memos(memos)

  redirect '/memos'
end

# メモ削除
delete '/memos/:id' do
  memos = load_memos
  memos.delete(params[:id])
  save_memos(memos)

  redirect '/memos'
end
