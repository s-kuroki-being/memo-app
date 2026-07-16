# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'rack/utils'
require 'securerandom'

enable :method_override

DB = SQLite3::Database.new('memos.db')
DB.results_as_hash = true

DB.execute <<~SQL
  CREATE TABLE IF NOT EXISTS memos (
    id TEXT PRIMARY KEY,
    title TEXT,
    content TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
  )
SQL

def row_to_memo(row)
  {
    'id' => row['id'],
    'title' => row['title'],
    'content' => row['content']
  }
end

def load_memos
  rows = DB.execute('SELECT id, title, content FROM memos ORDER BY created_at DESC')
  rows.each_with_object({}) do |row, memos|
    memos[row['id']] = row_to_memo(row)
  end
end

helpers do
  def find_memo(id)
    row = DB.get_first_row('SELECT id, title, content FROM memos WHERE id = ?', [id])
    row && row_to_memo(row)
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
  @memo = find_memo(params[:id])
  halt 404, 'Memo not found' if @memo.nil?

  erb :show
end

# 編集画面
get '/memos/:id/edit' do
  @memo = find_memo(params[:id])
  halt 404, 'Memo not found' if @memo.nil?

  erb :edit
end

# 新規メモ作成
post '/memos' do
  title = params[:title]&.strip
  content = params[:content]&.strip

  id = SecureRandom.uuid
  DB.execute('INSERT INTO memos (id, title, content) VALUES (?, ?, ?)', [id, title, content])

  redirect '/memos'
end

# 既存のメモを更新
patch '/memos/:id' do
  memo = find_memo(params[:id])
  halt 404, 'Memo not found' if memo.nil?

  DB.execute(
    'UPDATE memos SET title = ?, content = ? WHERE id = ?',
    [params[:title]&.strip, params[:content]&.strip, params[:id]]
  )

  redirect '/memos'
end

# メモ削除
delete '/memos/:id' do
  DB.execute('DELETE FROM memos WHERE id = ?', [params[:id]])

  redirect '/memos'
end
