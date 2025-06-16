create table rol(
    id_rol serial primary key,
    nombre varchar(50));

create table turno(
    id_turno serial primary key,
    hora_ini time NOT NULL,
    hora_fin time NOT NULL,
    ventas_realizadas int DEFAULT 0,
    total_efectivo numeric(10,2) DEFAULT 0);

create table reporte(
    id_reporte serial primary key,
    fecha_ini date NOT NULL,
    fecha_fin date NOT NULL,
    tipo_reporte varchar(50));

create table usuario(
    id_usuario serial primary key,
    nombre varchar(50),
    correo varchar,
    rfc varchar(50) unique,
    regimen_fiscal_cliente varchar(50),
    activo boolean default true,
    id_rol int NOT NULL,
    constraint fk_usuario_rol foreign key (id_rol) references rol(id_rol));

create table  credito(
    id_credito serial primary key,
    saldo_actual numeric(10,2) NOT NULL,
    id_usuario int unique,
    constraint fk_credito_usuario foreign key (id_usuario) references usuario(id_usuario));

create table categoria(
    id_categoria serial primary key,
    nombre varchar(50));

create table proveedor(
    id_proveedor serial primary key,
    nombre varchar(50));

create table promocion(
    id_promocion serial primary key,
    tipo varchar(50),
    descuento numeric(5,2) NOT NULL);

create table producto(
    id_producto serial primary key,
    codigo_barras varchar(20) unique NOT NULL,
    costo numeric(10,2) NOT NULL,
    nombre varchar(75),
    marca varchar(50),
    precio numeric(10,2) NOT NULL,
    unidad varchar(50),
    stock int default 0,
    id_categoria int,
    id_proveedor int,
    id_promocion int,
    constraint fk_producto_categoria foreign key (id_categoria) references categoria(id_categoria),
    constraint fk_producto_proveedor foreign key (id_proveedor) references proveedor(id_proveedor),
    constraint fk_producto_promocion foreign key (id_promocion) references promocion(id_promocion));

create table venta(
    id_venta serial primary key,
    fecha_hora timestamp NOT NULL,
    web_id varchar(50) unique,
    descuento_total numeric(10,2) default 0,
    IVA numeric(10,2) NOT NULL,
    metodo_pago varchar(30) NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    total numeric(10,2) NOT NULL,
    id_usuario int,  -- el cajero que registra la venta
    id_cliente int,  -- el cliente que realiza la compra
    constraint fk_venta_cajero foreign key (id_usuario) references usuario(id_usuario),
    constraint fk_venta_cliente foreign key (id_cliente) references usuario(id_usuario));

create table detalle(
    id_detalle serial primary key,
    cantidad int NOT NULL,
    descuento_unitario numeric(10,2) default 0,
    precio_unitario numeric(10,2) NOT NULL,
    id_venta int,
    id_producto int,
    constraint fk_detalle_venta foreign key (id_venta) references venta(id_venta),
    constraint fk_detalle_producto foreign key (id_producto) references producto(id_producto));

create table factura(
    id_factura serial primary key,
    fecha_emision timestamp NOT NULL,
    metodo_pago varchar(30) NOT NULL,
    rfc_tienda varchar(30) NOT NULL,
    web_id varchar(50) unique,
    rfc_cliente varchar(13),
    uso_cfdi varchar(50),
    regimen_fiscal_cliente varchar(50),
    regimen_fiscal_tienda varchar(50),
    constraint fk_factura_venta foreign key (web_id) references venta(web_id));

create table devolucion(
    id_devolucion serial primary key,
    fecha date NOT NULL,
    monto numeric(10,2) NOT NULL,
    tipo varchar(30) NOT NULL,
    autorizado_por varchar(100),
    id_venta int,
    constraint fk_devolucion_venta foreign key (id_venta) references venta(id_venta));

create table detalledev(
    id_detalledev serial primary key,
    motivo varchar(25) NOT NULL,
    cantidad int NOT NULL,
    descripcion text,
    id_devolucion int,
    constraint fk_detalledev_devolucion foreign key (id_devolucion) references devolucion(id_devolucion));
	
-------Inserción de Rol---------
insert into rol (id_rol, nombre) values
	(1, 'Administrador'),
	(2, 'Cajero'),
	(3, 'Cliente');

-------------------------------Inserción de Administrador--------------------------------------
insert into usuario(id_usuario, nombre, correo, activo, id_rol) values
	(2204, 'Juan Carlos Cornejo', 'juanczapi.22@gmail.com', TRUE, 1),
	(0901, 'Alan Elizalde', 'elalan@gmail.com', TRUE, 1),
	(1301, 'Esteban Saúl Mejía', 'sac.siete@gmail.com', TRUE, 1);

-------------------------------Inserción de Cajero----------------------------------------------
insert into usuario(id_usuario, nombre, correo, activo, id_rol) values
	(8765, 'Pedro Gonzalez', 'pedrope.go@gmail.com', TRUE, 2),
	(8764, 'Mariana Cuenta', 'marcu.1@mail.com', TRUE, 2);
	
-------------------------------Inserción de Cliente---------------------------------------------
WITH nombres AS (
    SELECT 
        ARRAY['Juan', 'María', 'Carlos', 'Ana', 'Luis', 'Sofía', 'José', 'Elena', 'Miguel', 'Lucía'] AS nombres,
        ARRAY['Pérez', 'Gómez', 'Ramírez', 'Fernández', 'Torres', 'Martínez', 'López', 'Díaz', 'Sánchez', 'Morales'] AS apellidos,
        ARRAY['601', '605', '606', '612', '615', '616'] AS regimenes
), ----Genera a partir de 6 nombre y 6 apellidos a los 100 clientes 
clientes AS (
    SELECT 
        nombres.nombres[(floor(random() * 10) + 1)::int] || ' ' ||
        nombres.apellidos[(floor(random() * 10) + 1)::int] AS nombre,
        
        'cliente' || gs || '@gmail.com' AS correo,
        
        -- RFC simulado con 4 letras + fecha ficticia + 3 letras
        UPPER(
            SUBSTRING(md5(random()::text), 1, 4) || 
            TO_CHAR(date '1970-01-01' + (random() * 18250)::int, 'YYMMDD') || 
            SUBSTRING(md5(random()::text), 1, 3)
        ) AS rfc,
        
        nombres.regimenes[(floor(random() * 6) + 1)::int] AS regimen_fiscal_cliente,
        
        3 AS id_rol
    FROM generate_series(1, 100) AS gs,
         nombres
)
INSERT INTO usuario (nombre, correo, rfc, regimen_fiscal_cliente, id_rol)
SELECT nombre, correo, rfc, regimen_fiscal_cliente, id_rol
FROM clientes;

------------------Insert Credito----------------------
INSERT INTO credito (saldo_actual, id_usuario)
SELECT 
    ROUND((random() * 500)::numeric, 2) AS saldo,
    u.id_usuario
FROM usuario u
WHERE u.id_rol = 3
  AND NOT EXISTS (
      SELECT 1
      FROM credito c
      WHERE c.id_usuario = u.id_usuario
  )
ORDER BY u.id_usuario DESC
LIMIT 100;

------------Consulta Clientes----------
select 
    u.id_usuario,
    u.nombre,
    u.correo,
    u.rfc,
    u.regimen_fiscal_cliente,
    c.saldo_actual
from usuario u
left join credito c ON u.id_usuario = c.id_usuario
where u.id_rol = 3;

----------------Inserción de Proveedor, categoría y promoción-------------
--Categorías de productos
insert into categoria (nombre) values
('Granos'), ('Lácteos'), ('Bebidas'), ('Abarrotes'), ('Limpieza');

--Proveedores
insert into proveedor (nombre) values
('Distribuidora Central'), ('Abarrotero'), ('Coca-Cola'), ('El Zorro'), ('Jesscarus');

--Promociones
insert into promocion (tipo, descuento) values
('3x1', 75.00),
('2x1', 50.00),
('Precio especial', 20.00);

-------------------Inserción de productos--------------------------
insert into producto (codigo_barras, costo, nombre, marca, precio, unidad, stock, id_categoria, id_proveedor, id_promocion)
values
	('750100000001', 6.5, 'Pan Integral', 'Bimbo', 9.1, 'kg', 31, 4, 2, 1),
	('750100000002', 8.0, 'Galletas Marías', 'Gamesa', 11.2, 'paquete', 32, 4, 3, 2),
	('750100000003', 8.0, 'Refresco Coca-Cola 600ml', 'Coca-Cola', 11.2, 'pieza', 33, 3, 4, 3),
	('750100000004', 9.5, 'Jabón de Lavandería', 'Zote', 13.3, 'botella', 34, 5, 5, NULL),
	('750100000005', 11.0, 'Yogurt Natural 1kg', 'Nestlé', 15.4, 'caja', 35, 2, 3, 1),
	('750100000006', 11.0, 'Servilletas 200pzas', 'Kimberly-Clark', 15.4, 'lata', 36, 4, 3, 2),
	('750100000007', 12.5, 'Cereal Corn Flakes 300g', 'Corn Flakes', 17.5, 'caja', 37, 4, 1, 3),
	('750100000008', 14.0, 'Papel Higiénico 4pzas', 'Petalo', 19.6, 'litro', 38, 4, 2, NULL),
	('750100000009', 14.0, 'Sal de Mesa 1kg', 'La Fina', 19.6, 'kg', 39, 1, 3, 1),
	('750100000010', 15.5, 'Azúcar Refinada 1kg', 'Pato', 21.7, 'paquete', 40, 1, 4, 2),
	('750100000011', 17.0, 'Café Soluble 100g', 'Nescafé', 23.8, 'pieza', 41, 1, 5, 3),
	('750100000012', 17.0, 'Aceite Vegetal 1L', 'Aceite', 23.8, 'botella', 42, 4, 2, NULL),
	('750100000013', 18.5, 'Sopa de Pasta 200g', 'La Moderna', 25.9, 'caja', 43, 4, 2, 1),
	('750100000014', 20.0, 'Frijol Negro 1kg', 'Great Value', 28.0, 'lata', 44, 1, 1, 2),
	('750100000015', 20.0, 'Arroz Blanco 1kg', 'Great Value', 28.0, 'frasco', 45, 1, 2, 3),
	('750100000016', 21.5, 'Atún en Agua 140g', 'Dolores', 30.1, 'litro', 46, 4, 3, NULL),
	('750100000017', 23.0, 'Mayonesa 400g', 'Hellmans', 32.2, 'kg', 47, 4, 4, 1),
	('750100000018', 23.0, 'Ketchup 500g', 'La Costeña', 32.2, 'paquete', 48, 4, 5, 2),
	('750100000019', 24.5, 'Detergente en Polvo 1kg', 'Escudo', 34.3, 'pieza', 49, 5, 2, 3),
	('750100000020', 6.0, 'Shampoo 750ml', 'Palmolive', 8.4, 'botella', 50, 4, 2, NULL),
	('750100000021', 6.0, 'Desodorante 100ml', 'Rexona', 8.4, 'caja', 51, 4, 1, 1),
	('750100000022', 7.5, 'Crema 400ml', 'Alpura', 10.5, 'lata', 52, 2, 1, 2),
	('750100000023', 9.0, 'Toallas Femeninas 10pzas', 'Saba', 12.6, 'frasco', 53, 4, 3, 3),
	('750100000024', 9.0, 'Cepillo Dental', 'Colgate', 12.6, 'litro', 54, 4, 4, NULL),
	('750100000025', 10.5, 'Pasta Dental 150g', 'Colgate', 14.7, 'kg', 55, 4, 1, 1),
	('750100000026', 12.0, 'Jugo de Naranja 1L', 'Jumex', 16.8, 'paquete', 56, 3, 4, 2),
	('750100000027', 12.0, 'Agua Embotellada 1.5L', 'Epura', 16.8, 'pieza', 57, 3, 4, 3),
	('750100000028', 13.5, 'Cerveza Lata 355ml', 'Modelo', 18.9, 'botella', 58, 3, 1, NULL),
	('750100000029', 15.0, 'Chocolate Barra', 'Carlos V', 21.0, 'caja', 59, 4, 2, 1),
	('750100000030', 15.0, 'Harina de Trigo 1kg', 'Harina', 21.0, 'lata', 60, 4, 3, 2),
	('750100000031', 16.5, 'Maicena 100g', 'La Moderna', 23.1, 'frasco', 61, 4, 4, 3),
	('750100000032', 18.0, 'Pan Molido 200g', 'La Moderna', 25.2, 'litro', 62, 4, 5, NULL),
	('750100000033', 18.0, 'Vinagre Blanco 1L', 'Vinagre', 25.2, 'kg', 63, 4, 3, 1),
	('750100000034', 19.5, 'Salsa Picante 150ml', 'Valentina', 27.3, 'paquete', 64, 4, 3, 2),
	('750100000035', 21.0, 'Chiles Enlatados', 'La Costeña', 29.4, 'pieza', 65, 4, 1, 3),
	('750100000036', 21.0, 'Sardinas 155g', 'Doleres', 29.4, 'botella', 66, 4, 2, NULL),
	('750100000037', 22.5, 'Gel Antibacterial 250ml', 'Cloralex', 31.5, 'caja', 67, 4, 3, 1),
	('750100000038', 24.0, 'Cloro 1L', 'Cloralex', 33.6, 'lata', 68, 5, 4, 2),
	('750100000039', 24.0, 'Desinfectante 500ml', 'Escudo', 33.6, 'frasco', 69, 5, 5, 3),
	('750100000040', 5.5, 'Esponja Multiuso', 'Esponja', 7.7, 'litro', 70, 5, 3, NULL),
	('750100000041', 7.0, 'Trapeador', 'vileda', 9.8, 'kg', 71, 5, 1, 1),
	('750100000042', 7.0, 'Escoba', 'vileda', 9.8, 'paquete', 72, 5, 1, 2),
	('750100000043', 8.5, 'Limpiavidrios 500ml', 'limpiatodo', 11.9, 'pieza', 73, 5, 2, 3),
	('750100000044', 10.0, 'Toallas Húmedas', 'Zote', 14.0, 'botella', 74, 5, 3, NULL),
	('750100000045', 10.0, 'Crema Dental Infantil', 'colgate', 14.0, 'caja', 75, 4, 4, 1),
	('750100000046', 11.5, 'Suavizante 850ml', 'Kimberly-Clark', 16.1, 'lata', 76, 5, 5, 2),
	('750100000047', 13.0, 'Detergente Líquido 1L', 'Fabuloso', 18.2, 'frasco', 77, 5, 1, 3),
	('750100000048', 13.0, 'Cereal Avena 250g', 'Great Value', 18.2, 'litro', 78, 4, 1, NULL),
	('750100000049', 14.5, 'Mermelada de Fresa 500g', 'La Costeña', 20.3, 'kg', 79, 4, 1, 1),
	('750100000050', 16.0, 'Leche Entera 1L', 'Lala', 22.4, 'paquete', 30, 2, 2, 2),
	('750100000051', 16.0, 'Pan Integral', 'Bimbo', 22.4, 'pieza', 31, 4, 3, 3),
	('750100000052', 17.5, 'Galleta Emperador', 'Gamesa', 24.5, 'botella', 32, 4, 4, NULL),
	('750100000053', 19.0, 'Refresco Coca-Cola 600ml', 'Coca-Cola', 26.6, 'caja', 33, 3, 5, 1),
	('750100000054', 19.0, 'Jabón de Lavandería', 'Great Value', 26.6, 'lata', 34, 5, 3, 2),
	('750100000055', 20.5, 'Yogurt Natural 1kg', 'Danone', 28.7, 'frasco', 35, 2, 4, 3),
	('750100000056', 22.0, 'Servilletas 200pzas', 'Great Value', 30.8, 'litro', 36, 4, 1, NULL),
	('750100000057', 22.0, 'Cereal Corn Flakes 300g', 'Corn Flakes', 30.8, 'kg', 37, 4, 2, 1),
	('750100000058', 23.5, 'Papel Higiénico 4pzas', 'Petalo', 32.9, 'paquete', 38, 4, 3, 2),
	('750100000059', 25.0, 'Sal Grano 1kg', 'La Fina', 35.0, 'pieza', 39, 1, 4, 3),
	('750100000060', 5.0, 'Azúcar Mazcabada 1kg', 'Great Value', 7.0, 'bolsa', 40, 1, 5, NULL),
	('750100000061', 6.5, 'Café Soluble 100g', 'Nescafé', 9.1, 'frasco', 41, 1, 5, 1),
	('750100000062', 8.0, 'Aceite Vegetal 1L', 'Aceite', 11.2, 'lata', 42, 4, 5, 2),
	('750100000063', 8.0, 'Sopa de Pasta 200g', 'La Moderna', 11.2, 'frasco', 43, 4, 1, 3),
	('750100000064', 9.5, 'Frijol Negro 1kg', 'Great Value', 13.3, 'bolsa', 44, 1, 2, NULL),
	('750100000065', 11.0, 'Arroz Blanco 1kg', 'Great Value', 15.4, 'kg', 45, 1, 3, 1),
	('750100000066', 11.0, 'Atún en Agua 140g', 'Dolores', 15.4, 'lata', 46, 4, 4, 2),
	('750100000067', 12.5, 'Mayonesa 400g', 'Mckormick', 17.5, 'pieza', 47, 4, 5, 3),
	('750100000068', 14.0, 'Ketchup 500g', 'Great Value', 19.6, 'botella', 48, 4, 2, NULL),
	('750100000069', 14.0, 'Detergente en Polvo 1kg', 'Cloralex', 19.6, 'caja', 49, 5, 1, 1),
	('750100000070', 15.5, 'Shampoo 750ml', 'Sedal', 21.7, 'lata', 50, 4, 1, 2),
	('750100000071', 17.0, 'Desodorante 100ml', 'Rexona', 23.8, 'frasco', 51, 4, 2, 3),
	('750100000072', 17.0, 'Crema Corporal 400ml', 'Dove', 23.8, 'litro', 52, 4, 3, NULL),
	('750100000073', 18.5, 'Toallas Femeninas 10pzas', 'Saba', 25.9, 'kg', 53, 4, 4, 1),
	('750100000074', 20.0, 'Cepillo Dental', 'Colgate', 28.0, 'paquete', 54, 4, 5, 2),
	('750100000075', 20.0, 'Pasta Dental 150g', 'Colgate', 28.0, 'pieza', 55, 4, 3, 3),
	('750100000076', 21.5, 'Jugo de Naranja 1L', 'Jumex', 30.1, 'botella', 56, 3, 5, NULL),
	('750100000077', 23.0, 'Agua Embotellada 1.5L', 'Epura', 32.2, 'caja', 57, 3, 1, 1),
	('750100000078', 23.0, 'Cerveza Lata 355ml', 'Corona', 32.2, 'botella', 58, 3, 2, 2),
	('750100000079', 24.5, 'Chocolate Barra', 'Kisses', 34.3, 'caja', 59, 4, 3, 3),
	('750100000080', 6.0, 'Harina de Trigo 1kg', 'Great Value', 8.4, 'caja', 60, 4, 4, NULL),
	('750100000081', 6.0, 'Maicena 100g', 'Great Value', 8.4, 'kg', 61, 4, 5, 1),
	('750100000082', 7.5, 'Pan Molido 200g', 'Gamesa', 10.5, 'paquete', 62, 4, 2, 2),
	('750100000083', 9.0, 'Vinagre Blanco 1L', 'Great Value', 12.6, 'pieza', 63, 4, 2, 3),
	('750100000084', 9.0, 'Salsa Picante 150ml', 'Valentina', 12.6, 'botella', 64, 4, 1, NULL),
	('750100000085', 10.5, 'Chiles Enlatados', 'La Costeña', 14.7, 'lata', 65, 4, 2, 1),
	('750100000086', 12.0, 'Sardinas 155g', 'Dolores', 16.8, 'lata', 66, 4, 3, 2),
	('750100000087', 12.0, 'Gel Antibacterial 250ml', 'Cloralex', 16.8, 'frasco', 67, 4, 4, 3),
	('750100000088', 13.5, 'Cloro 1L', 'Cloralex', 18.9, 'litro', 68, 5, 5, NULL),
	('750100000089', 15.0, 'Desinfectante 500ml', 'Cloralex', 21.0, 'kg', 69, 5, 5, 1),
	('750100000090', 15.0, 'Esponja Multiuso', 'Great Value', 21.0, 'paquete', 70, 5, 5, 2),
	('750100000091', 16.5, 'Trapeador', 'Vileda', 23.1, 'pieza', 71, 5, 1, 3),
	('750100000092', 18.0, 'Escoba', 'Vileda', 25.2, 'pieza', 72, 5, 2, NULL),
	('750100000093', 18.0, 'Limpiavidrios 500ml', 'Vileda', 25.2, 'caja', 73, 5, 3, 1),
	('750100000094', 19.5, 'Toallas Húmedas', 'Cloralex', 27.3, 'lata', 74, 5, 4, 2),
	('750100000095', 21.0, 'Sopa Instantanea', 'Maruchan', 29.4, 'paquete', 75, 4, 5, 3),
	('750100000096', 21.0, 'Suavizante 850ml', 'Fabuloso', 29.4, 'litro', 76, 5, 2, NULL),
	('750100000097', 22.5, 'Detergente Líquido 1L', 'Cloralex', 31.5, 'kg', 77, 5, 3, 1),
	('750100000098', 24.0, 'Cereal Avena 250g', 'Kellogs', 33.6, 'paquete', 78, 4, 1, 2),
	('750100000099', 24.0, 'Mermelada de Fresa 500g', 'Moderna', 23.6, 'pieza', 79, 4, 2, 3),
	('750100000100', 5.5, 'Naranjada 1L', 'Peñafiel', 32.7, 'botella', 30, 3, 3, NULL);


----------------Consulta de producto por categoría---------------------------
select p.*
from producto p
join categoria c ON p.id_categoria = c.id_categoria
where c.id_categoria = 3;

-----------------Consulta de producto por proveedor--------------------------
select p.*
from producto p
join proveedor c on p.id_proveedor = c.id_proveedor
where c.id_proveedor = 2;

-----------------Consulta de producto por promoción--------------------------
select p.*
from producto p
join promocion c on p.id_promocion = c.id_promocion
where c.id_promocion = 1;

