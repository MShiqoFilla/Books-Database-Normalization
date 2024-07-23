-- Here we create tables to store all the data from the staging table

create table books_data_ids (
	main_id serial primary key,
	isbn13 varchar(40),
	judul varchar(300),
	author varchar(170),
	kode_kategori varchar(5),
	kategori varchar(55),
	ketersediaan varchar(30),
	harga_asli int,
	format varchar(45),
	tahun_terbit varchar(10),
	bahasa varchar(48),
	penerbit varchar(110),
	halaman int, 
	link_buku varchar(500),
	deskripsi text
)

insert into books_data_ids (
	isbn13,
	judul,
	author,
	kode_kategori,
	kategori,
	ketersediaan,
	harga_asli,
	format,
	tahun_terbit,
	bahasa,
	penerbit,
	halaman, 
	link_buku,
	deskripsi
) select * from books_data bd 


select * from books_data_ids  

-- Here we create fact tables

create table facts_buku (
	main_id int primary key,
	isbn13 varchar(40),
	judul varchar(300),
	harga_asli int,
	tahun_terbit varchar(10),
	halaman int,
	link_buku varchar(500),
	deskripsi text,
	unique(main_id)
)


insert into facts_buku (main_id, isbn13, judul, harga_asli, tahun_terbit, halaman, link_buku, deskripsi)
select main_id, isbn13, judul, harga_asli, tahun_terbit, halaman, link_buku, deskripsi from books_data_ids

select * from facts_buku fb order by main_id 

-- Here we create all dimensional tables
-- author

create table author_buku (
	id_author serial, author varchar(200), primary key (id_author)
)

select * from author_buku ab 

insert into author_buku (author)
select distinct author from books_data_ids where author != '' and author is not null order by author 

-- kategori

create table kategori_buku (
	id_category varchar(4),
	category_name varchar(40), primary key (id_category)
)

select * from kategori_buku kb 

insert into kategori_buku (id_category, category_name) 
select distinct kode_kategori, kategori from books_data_ids 

-- ketersediaan

create table ketersediaan_buku (
	id_ketersediaan serial, 
	ketersediaan varchar(40), primary key (id_ketersediaan)
)

insert into ketersediaan_buku (ketersediaan) select distinct ketersediaan from books_data_ids 

select * from ketersediaan_buku kb 

-- format 

create table format_buku (
	id_format serial,
	format varchar(40), primary key (id_format)
)

insert into format_buku (format) select distinct format from books_data_ids where format is not null and format != '' order by format

select * from format_buku fb 

-- bahasa

create table bahasa_buku (
	id_lang serial,
	bahasa varchar(30), primary key (id_lang)
)

insert into bahasa_buku (bahasa)
select distinct bahasa from books_data_ids where bahasa is not null and bahasa != ''

select * from bahasa_buku bb 

-- penerbit

create table penerbit_buku (
	id_penerbit SERIAL, 
	penerbit varchar(110), primary key (id_penerbit) 
)

insert into penerbit_buku (penerbit) select distinct penerbit from books_data_ids order by penerbit 

select * from penerbit_buku pb 

-- Relationship Table

create table relationship (
	main_id int primary key,
	id_author int,
	id_category varchar(5), 
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

select * from relationship 

insert into relationship (main_id, id_author, id_category, id_ketersediaan, id_format, id_lang, id_penerbit) 
select 
	facts_buku.main_id,
	author_buku.id_author, 
	kategori_buku.id_category,
	ketersediaan_buku.id_ketersediaan,
	format_buku.id_format, 
	bahasa_buku.id_lang,
	penerbit_buku.id_penerbit from books_data_ids 
	left join facts_buku on books_data_ids.main_id = facts_buku.main_id 
	left join author_buku on books_data_ids.author = author_buku.author
	left join kategori_buku on books_data_ids.kategori = kategori_buku.category_name 
	left join ketersediaan_buku on books_data_ids.ketersediaan = ketersediaan_buku.ketersediaan
	left join format_buku on books_data_ids.format = format_buku.format 
	left join bahasa_buku on books_data_ids.bahasa = bahasa_buku.bahasa 
	left join penerbit_buku on books_data_ids.penerbit = penerbit_buku.penerbit
	
-- Tes QUERY

select facts_buku.main_id, facts_buku.judul, penerbit_buku.penerbit from facts_buku
	left join relationship on facts_buku.main_id = relationship.main_id 
	left join penerbit_buku on relationship.id_penerbit = penerbit_buku.id_penerbit
	left join kategori_buku on relationship.id_category = kategori_buku.id_category 
	where penerbit_buku.id_penerbit = 70 and kategori_buku.id_category = '92'
	order by facts_buku.main_id 
	
select main_id, judul, penerbit from books_data_ids bdi 
where kategori = 'komik' and penerbit = 'Elex Media Komputindo' order by main_id 
	