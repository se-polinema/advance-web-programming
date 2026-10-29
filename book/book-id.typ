#import "/template.typ": *
#show: book.with(lang: "id")

#show: frontmatter
#include "frontmatter/id/titlepage.typ"
#cleardoublepage()
#include "frontmatter/id/copyright.typ"
#cleardoublepage()
#include "frontmatter/id/preface.typ"
#include "frontmatter/id/preface2.typ"

#toc()
#list-of-tables()

#show: mainmatter
#part([Fondasi Laravel dan Arsitektur Web], ([Bab 1 • Arsitektur Web Modern dan Ekosistem Laravel], [Bab 2 • Protokol HTTP dan Pola MVC], [Bab 3 • Antarmuka dengan Blade, Tailwind, dan Alpine],))
#include "chapters/id/chapter01-arsitektur-web-modern.typ"
#include "chapters/id/chapter02-http-dan-mvc.typ"
#include "chapters/id/chapter03-blade-dan-tailwind.typ"
#part([Data dan Eloquent], ([Bab 4 • Desain Basis Data, Migrasi, dan Seeding], [Bab 5 • Eloquent ORM dan Relasi], [Bab 6 • Validasi dan Keamanan Input],))
#include "chapters/id/chapter04-desain-basis-data.typ"
#include "chapters/id/chapter05-eloquent-dan-relasi.typ"
#include "chapters/id/chapter06-validasi-input.typ"
#part([Keamanan, Laporan, dan API], ([Bab 7 • Autentikasi, Otorisasi, dan RBAC], [Bab 8 • Pengolahan Data: Impor, Ekspor, dan Antrean], [Bab 9 • Merancang dan Membangun REST API],))
#include "chapters/id/chapter07-autentikasi-dan-otorisasi.typ"
#include "chapters/id/chapter08-pengolahan-data.typ"
#include "chapters/id/chapter09-membangun-rest-api.typ"
#part([Menuju Aplikasi Siap Produksi], ([Bab 10 • Pengujian dan Kualitas Aplikasi], [Bab 11 • Optimasi, Deployment, dan Dokumentasi], [Bab 12 • Studi Kasus Menyeluruh: Membangun Simple POS dari Nol],))
#include "chapters/id/chapter10-pengujian-aplikasi.typ"
#include "chapters/id/chapter11-optimasi-dan-deployment.typ"
#include "chapters/id/chapter12-studi-kasus-menyeluruh.typ"

#show: appendices
#include "appendices/id/rest-api-reference.typ"
#include "appendices/id/cli-reference.typ"
#include "appendices/id/topik-lanjutan.typ"
#include "appendices/id/glossary.typ"
#include "appendices/id/instalasi.typ"

#show: backmatter
#bibliography-section("references.bib")
#index-section()
