create extension if not exists pgcrypto;
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade, full_name text not null, document text, phone text, city text, role text not null default 'student' check(role in ('student','admin')), created_at timestamptz default now());
create table if not exists public.courses(id text primary key, title text not null, description text, hours int not null, price_cop bigint not null, active boolean default true, modules jsonb not null default '[]');
create table if not exists public.enrollments(id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete cascade, course_id text references public.courses(id), status text not null default 'pending' check(status in ('pending','paid','active','completed','cancelled')), progress int default 0, created_at timestamptz default now(), unique(user_id,course_id));
create table if not exists public.payments(id uuid primary key default gen_random_uuid(), enrollment_id uuid references public.enrollments(id) on delete cascade, reference text unique not null, wompi_transaction_id text unique, amount_cop bigint not null, status text not null default 'PENDING', raw_event jsonb, created_at timestamptz default now(), updated_at timestamptz default now());
create table if not exists public.certificates(id uuid primary key default gen_random_uuid(), enrollment_id uuid unique references public.enrollments(id) on delete cascade, certificate_number text unique not null, issued_at timestamptz default now());
create index if not exists enrollments_user_idx on public.enrollments(user_id); create index if not exists payments_reference_idx on public.payments(reference);

insert into public.courses(id,title,description,hours,price_cop,modules) values
('GE','Gestión empresarial y creación de negocios','Convierte una idea en un negocio organizado y rentable.',40,350000,'["Modelo de negocio","Formalización y organización","Costos y rentabilidad","Ventas y servicio","Marketing y crecimiento"]'),
('FC','Finanzas, contabilidad y manejo del dinero','Herramientas prácticas para controlar dinero, presupuesto y flujo de caja.',60,550000,'["Presupuesto","Flujo de caja","Contabilidad básica","Ahorro e inversión","Endeudamiento responsable"]'),
('CC','Crédito, cartera y gestión de cobranza','Análisis de crédito, cartera y cobranza.',50,500000,'["Perfil del cliente","Capacidad de pago","Políticas de crédito","Gestión de cartera","Cobranza y riesgo"]'),
('PACK','Paquete profesional: 3 cursos','Tres programas con certificación.',150,990000,'["Gestión empresarial","Finanzas y contabilidad","Crédito y cartera","Proyecto final","Certificación"]') on conflict(id) do nothing;

alter table public.profiles enable row level security; alter table public.courses enable row level security; alter table public.enrollments enable row level security; alter table public.payments enable row level security; alter table public.certificates enable row level security;
create policy "courses public read" on public.courses for select using(active=true);
create policy "profile own" on public.profiles for all using(auth.uid()=id) with check(auth.uid()=id);
create policy "enrollment own" on public.enrollments for select using(auth.uid()=user_id);
create policy "certificate own" on public.certificates for select using(exists(select 1 from public.enrollments e where e.id=enrollment_id and e.user_id=auth.uid()));
-- Las operaciones administrativas y webhooks usan service_role en el servidor.
