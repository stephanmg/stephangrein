create table if not exists comments (
  title string not null,
  text string not null,
  author string not null,
  article_id integer not null,
  id integer primary key autoincrement
);
