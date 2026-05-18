# frozen_string_literal: true

# bundle exec ruby app.rb -o 0.0.0.0
require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'

enable :method_override

def load_memos
  JSON.parse(File.read('memos.json'))
rescue Errno::ENOENT, JSON::ParserError
  {}
end

def save_memos(memos)
  File.open('memos.json', 'w') do |f|
    f.write(JSON.pretty_generate(memos))
  end
end

# メモアプリ作成
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
  @memo_id = params[:id]
  @memo = memos[@memo_id]
  halt 404, 'Memo not found' if @memo.nil?

  erb :show
end

# 編集画面
get '/memos/:id/edit' do
  memos = load_memos
  @memo_id = params[:id]
  @memo = memos[@memo_id]
  halt 404, 'Memo not found' if @memo.nil?

  erb :edit
end

# 保存処理
post '/memos' do
  title = params[:title]&.strip
  content = params[:content]&.strip

  if title.nil? || title.empty?
    @error = 'タイトルを入力してください。'
    return erb :new
  end

  id = Time.now.to_i.to_s
  memos = load_memos

  memos[id] = { 'title' => title, 'content' => content }

  save_memos(memos)

  redirect '/memos'
end

# メモ更新
patch '/memos/:id' do
  memos = load_memos
  memo = memos[params[:id]]
  halt 404, 'Memo not found' if memo.nil?

  title = params[:title]&.strip

  if title.nil? || title.empty?
    @memo_id = params[:id]
    @memo = { 'title' => params[:title], 'content' => params[:content] }
    @error = 'タイトルを入力してください。'
    return erb :edit
  end

  memo['title'] = title
  memo['content'] = params[:content]&.strip
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
