-- Data previously exported from postgresql to be csv file. Later on the csv file is imported to this SMSS to create the same database in SQL Server

select * from books_data_ids order by main_id

-- Create table than contains information of ISBN, title, price, link, description, etc of the books

create table facts_buku (
	main_id int identity(1,1) primary key,
	isbn13 varchar(40),
	judul varchar(300),
	harga_asli int,
	tahun_terbit varchar(10),
	halaman int,
	link_buku varchar(500),
	deskripsi text,
	unique(main_id)
)

SET IDENTITY_INSERT facts_buku ON

insert into facts_buku (main_id, isbn13, judul, harga_asli, tahun_terbit, halaman, link_buku, deskripsi)
select main_id, isbn13, judul, harga_asli, tahun_terbit, halaman, link_buku, deskripsi from books_data_ids

select * from facts_buku

-- Create table dimension author_buku

create table author_buku (
	id_author int identity(1,1) primary key, author varchar(200)
)

insert into author_buku (author)
select distinct author from books_data_ids where author != '' and author is not null order by author 

select count(*) from author_buku

-- Create table kategori_buku

create table kategori_buku (
	id_category varchar(4),
	category_name varchar(40), primary key (id_category)
)

insert into kategori_buku (id_category, category_name) 
select distinct kode_kategori, kategori from books_data_ids

-- Create table ketersediaan_buku

create table ketersediaan_buku (
	id_ketersediaan int identity(1,1), 
	ketersediaan varchar(40), primary key (id_ketersediaan)
)

insert into ketersediaan_buku (ketersediaan) select distinct ketersediaan from books_data_ids 

-- Create table format_buku

create table format_buku (
	id_format int identity(1,1),
	format varchar(40), primary key (id_format)
)

insert into format_buku (format) select distinct format from books_data_ids where format is not null and format != '' order by format

select * from format_buku fb 

-- Create table bahasa_buku

create table bahasa_buku (
	id_lang int identity(1,1),
	bahasa varchar(30), primary key (id_lang)
)

insert into bahasa_buku (bahasa)
select distinct bahasa from books_data_ids where bahasa is not null and bahasa != ''

select * from bahasa_buku bb 

-- Create table penerbit_buku

create table penerbit_buku (
	id_penerbit int identity(1,1), 
	penerbit varchar(110), primary key (id_penerbit) 
)

insert into penerbit_buku (penerbit) select distinct penerbit from books_data_ids order by penerbit 

select * from penerbit_buku pb 

-- Create Relationship table
-- Table relationship will connect all the other tables using foreign keys

create table relationship (
	main_id int primary key,
	id_author int,
	id_category varchar(4), 
	id_ketersediaan int,
	id_format int,
	id_lang int,
	id_penerbit int,
	constraint fk_id foreign key (main_id) references facts_buku(main_id),
	constraint fk_author foreign key (id_author) references author_buku(id_author),
	constraint fk_category foreign key (id_category) references kategori_buku(id_category),
	constraint fk_ketersediaan foreign key (id_ketersediaan) references ketersediaan_buku(id_ketersediaan),
	constraint fk_format foreign key (id_format) references format_buku(id_format),
	constraint fk_bahasa foreign key (id_lang) references bahasa_buku(id_lang),
	constraint fk_penerbit foreign key (id_penerbit) references penerbit_buku(id_penerbit)
)

insert into relationship (main_id, id_author, id_category, id_ketersediaan, id_format, id_lang, id_penerbit) 
select 
	facts_buku.main_id,
	author_buku.id_author, 
	kategori_buku.id_category,
	ketersediaan_buku.id_ketersediaan,
	format_buku.id_format, 
	bahasa_buku.id_lang,
	penerbit_buku.id_penerbit from books_data_ids 
	LEFT JOIN facts_buku on (books_data_ids.main_id = facts_buku.main_id) 
	left join author_buku on (books_data_ids.author = author_buku.author)
	left join kategori_buku on (books_data_ids.kategori = kategori_buku.category_name) 
	left join ketersediaan_buku on (books_data_ids.ketersediaan = ketersediaan_buku.ketersediaan)
	left join format_buku on (books_data_ids.format = format_buku.format)
	left join bahasa_buku on (books_data_ids.bahasa = bahasa_buku.bahasa)
	left join penerbit_buku on (books_data_ids.penerbit = penerbit_buku.penerbit)



-- TES QUERY
-- This query to checked that the tables have been connected as one system

select facts_buku.main_id, facts_buku.judul, penerbit_buku.penerbit from facts_buku
	left join relationship on facts_buku.main_id = relationship.main_id 
	left join penerbit_buku on relationship.id_penerbit = penerbit_buku.id_penerbit
	left join kategori_buku on relationship.id_category = kategori_buku.id_category 
	where penerbit_buku.id_penerbit = 70 and kategori_buku.id_category = '92'
	order by facts_buku.main_id 