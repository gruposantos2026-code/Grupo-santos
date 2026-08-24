# Grupo Santo 3.0

Versión preparada para producción con:
- Supabase Auth/Postgres/RLS como base de datos y autenticación.
- Servidor Node/Express para operaciones privilegiadas.
- Wompi Checkout: referencia única, firma de integridad y webhook validado.
- Estados de matrícula y pagos.
- Certificados PDF automáticos al completar una matrícula.
- Panel administrativo y estadísticas.

## Instalación
1. Instala Node.js 20+.
2. Crea un proyecto en Supabase.
3. Ejecuta `supabase/schema.sql` en SQL Editor.
4. Copia `.env.example` a `.env` y coloca las credenciales reales.
5. Ejecuta `npm install` y luego `npm start`.
6. Publica el servidor con HTTPS.
7. En Wompi configura el webhook `/api/wompi/webhook` y usa las llaves del ambiente correspondiente.

**No pongas nunca `SUPABASE_SERVICE_ROLE_KEY`, el secreto de integridad ni el secreto de eventos en el frontend.**

### Importante sobre Wompi
La integración usa una referencia única y firma SHA-256. El webhook es la fuente de verdad para aprobar el pago; la redirección no debe usarse para marcar una transacción como aprobada.

Antes de cobrar dinero real, configura las llaves de producción y prueba primero en Sandbox.
