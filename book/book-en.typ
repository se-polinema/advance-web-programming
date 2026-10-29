#import "/template.typ": *
#show: book.with(lang: "en")

#show: frontmatter
#include "frontmatter/en/titlepage.typ"
#cleardoublepage()
#include "frontmatter/en/copyright.typ"
#cleardoublepage()
#include "frontmatter/en/preface.typ"
#include "frontmatter/en/preface2.typ"

#toc()
#list-of-tables()

#show: mainmatter
#part([Laravel Foundations and Web Architecture], ([Chapter 1 • Modern Web Architecture and the Laravel Ecosystem], [Chapter 2 • HTTP Protocol and the MVC Pattern], [Chapter 3 • Building Interfaces with Blade, Tailwind, and Alpine],))
#include "chapters/en/chapter01-arsitektur-web-modern.typ"
#include "chapters/en/chapter02-http-dan-mvc.typ"
#include "chapters/en/chapter03-blade-dan-tailwind.typ"
#part([Data and Eloquent], ([Chapter 4 • Database Design, Migrations, and Seeding], [Chapter 5 • Eloquent ORM and Relationships], [Chapter 6 • Validation and Input Security],))
#include "chapters/en/chapter04-desain-basis-data.typ"
#include "chapters/en/chapter05-eloquent-dan-relasi.typ"
#include "chapters/en/chapter06-validasi-input.typ"
#part([Security, Reports, and APIs], ([Chapter 7 • Authentication, Authorization, and RBAC], [Chapter 8 • Data Processing: Import, Export, and Queues], [Chapter 9 • Designing and Building a REST API],))
#include "chapters/en/chapter07-autentikasi-dan-otorisasi.typ"
#include "chapters/en/chapter08-pengolahan-data.typ"
#include "chapters/en/chapter09-membangun-rest-api.typ"
#part([Toward a Production-Ready Application], ([Chapter 10 • Testing and Application Quality], [Chapter 11 • Optimization, Deployment, and Documentation], [Chapter 12 • Full Case Study: Building Simple POS From Scratch],))
#include "chapters/en/chapter10-pengujian-aplikasi.typ"
#include "chapters/en/chapter11-optimasi-dan-deployment.typ"
#include "chapters/en/chapter12-studi-kasus-menyeluruh.typ"

#show: appendices
#include "appendices/en/rest-api-reference.typ"
#include "appendices/en/cli-reference.typ"
#include "appendices/en/advanced-topics.typ"
#include "appendices/en/glossary.typ"
#include "appendices/en/installation-guide.typ"

#show: backmatter
#bibliography-section("references.bib")
#index-section()
