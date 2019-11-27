SELECT
	A.id                                                                   AS Id
	,A.order_id																														 AS id_carrinho
	,A.status                                                              AS Status
	,CASE
		WHEN    A.status = 0   THEN  'Carrinho Abandonado'
		WHEN    A.status = 1   THEN  'Pendente'
		WHEN    A.status = 2   THEN  'Aprovado'
		WHEN    A.status = 3   THEN  'Cancelado/Recusado'
		WHEN    A.status = 4   THEN  'Aprovado'
		WHEN    A.status = 5   THEN  'Cancelado/Recusado'
		WHEN    A.status = 6   THEN  'Cancelado/Recusado'
		WHEN    A.status = 7   THEN  'Aprovado'
		WHEN    A.status = 8   THEN  'Aprovado'
		WHEN    A.status = 9   THEN  'Pendente'
		WHEN    A.status = 10   THEN  'Pendente' -- Alterei o 10 para 'Pendente' em vez de 'Indefinido'
		WHEN    A.status = 11   THEN  'Pendente'
		WHEN    A.status = 12   THEN  'Pendente'
		WHEN    A.status = 13   THEN  'Pendente' -- Estava em Aprovado mudou para 'Pendente'
		WHEN    A.status = 14   THEN  'Aprovado'
		WHEN    A.status = 15   THEN  'Pendente' -- foram incluídos o 15 e 16 a 21/11/18
		WHEN	A.status = 16   THEN  'Pendente'
		ELSE  NULL
		END                                                                 Desc_Status
	,B.user_id                                                             AS Id_Cliente
	,UPPER(TRIM(D.fantasy_name))                                           AS Clt_Nm_Fantasia
	,UPPER(TRIM(D.social_name))                                            AS Clt_Razao
	,A.distributor_id                                                      AS Id_Distribuidor
	,UPPER(TRIM(E.fantasy_name))                                           AS For_Nm_Fantasia
	,UPPER(TRIM(E.social_name))                                            AS For_Razao
	,UPPER(TRIM(CASE
      WHEN CONCAT(G.name,' ',G.type,' ',G.packaging,' ',G.weight_qty, ' - ',G.brand) = '    - '
      THEN CONCAT(C.sku_name,' - ',C.brand)
      ELSE CONCAT(G.name,' ',G.type,' ',G.packaging,' ',G.weight_qty, ' - ',G.brand)
    END))																	AS Produto
	,to_char(A.sended_on, 'YYYYMM')                                         AS AnoMes_Status_Pedido
	,to_char(A.sended_on, 'DD-MM-YYYY')                                     AS Data_Status_Pedido
	,(C.count*C.stock_price)                                                AS VolumePedidos
	,CASE
		WHEN
		A.status IN (2,4,7,8,14)
		THEN  (C.count*C.stock_price)
		ELSE  NULL
		END                                                                AS VolumeCompras
	,CASE
		WHEN
		A.status IN (1,9,10,11,12,13,15,16) --Acrescentei o 10
		THEN  (C.count*C.stock_price)
		ELSE  NULL
		END                                                                	AS VolumePendente
	,CASE
		WHEN
		A.status IN (3,5,6)
		THEN  (C.count*C.stock_price)
		ELSE  NULL
		END                                                                	AS VolumeCanceladoRecusado
	,CASE
		WHEN A.sended_on >= (date_trunc('day',NOW() - INTERVAL '31days'))
		AND A.sended_on < (date_trunc('day', NOW()))
		THEN 1
		ELSE NULL
		END                                                      			AS Flag30Dias
	,CASE
		WHEN CAST(TO_CHAR(NOW(), 'MM')  AS FLOAT) >= CAST(TO_CHAR(A.sended_on, 'MM')  AS FLOAT)
		THEN 1
		ELSE    NULL
		END                                                            		AS Flag_AcumuladoMes --permite ver o que aconteceu de acumulado nos anos até ao mês presente
	,CASE
		WHEN  TO_CHAR(NOW(), 'DD-MM-YYYY') = TO_CHAR(A.sended_on, 'DD-MM-YYYY')
		THEN 1
		ELSE    NULL
		END                                                            		AS Flag_Dia

FROM
         orders_orderstatus                                 A

LEFT JOIN
         orders_order                                       B
         ON A.order_id = B.id

LEFT JOIN
         orders_orderproduct                                C
         ON A.order_id = C.order_id
		AND A.distributor_id = C.distributor_id

LEFT JOIN
         users_consumerprofile                              D
         ON B.user_id = D.user_id

LEFT JOIN
         users_distributorprofile                           E
         ON A.distributor_id = E.user_id

LEFT JOIN
         sku_skuproductsrelation                            F
         ON C.product_id = F.product_id

LEFT JOIN
         sku_sku                                            G
         ON F.sku_id = G.id

WHERE
    A.status <> 0
	AND C.product_id IS NOT NULL
ORDER BY A.sended_on DESC

SELECT
	to_char(A.sended_on, 'YYYYMM')                                  AS AnoMes_Status_Pedido
  ,COUNT(DISTINCT B.user_id)																			AS Clientes
  ,Count(DISTINCT a.id) as pedidos
  ,count(distinct b.id) as carrinhos
  ,count(distinct c.id) as produtos
  ,count(distinct e.id) as distribuidores
  ,count(distinct E.address_city_id) as cidades
	,SUM(CASE
		WHEN
		A.status IN (2,4,7,8,14)
		THEN  (C.count*C.stock_price)
		ELSE  NULL
		END)                                                           AS VolumeCompras

FROM
         orders_orderstatus                                 A

LEFT JOIN
         orders_order                                       B
         ON A.order_id = B.id

LEFT JOIN
         orders_orderproduct                                C
         ON A.order_id = C.order_id
		AND A.distributor_id = C.distributor_id

LEFT JOIN
         users_consumerprofile                              D
         ON B.user_id = D.user_id

LEFT JOIN
         users_distributorprofile                           E
         ON A.distributor_id = E.user_id

LEFT JOIN
         sku_skuproductsrelation                            F
         ON C.product_id = F.product_id

LEFT JOIN
         sku_sku                                            G
         ON F.sku_id = G.id

WHERE
    A.status <> 0
	AND C.product_id IS NOT NULL
GROUP BY
	to_char(A.sended_on, 'YYYYMM')

SELECT
       A.ID carrinho_id,
       A.created_on,
       a.user_id,
       /*B.ID pedido_id,*/
       C.brand
FROM orders_order A
/*LEFT JOIN orders_orderstatus B
	ON A.ID = B.order_id*/
LEFT JOIN orders_orderproduct C
	ON C.order_id = A.ID
WHERE a.id in (1408746)
ORDER BY created_on DESC

SELECT * FROM lazyuser_lazyuser WHERE user_id IN (1366180,1366140) ORDER BY created desc

SELECT count(*) from products_product where archived = True

SELECT count(*) from sku_sku where published = True

Select count(distinct address_city_id) from users_distributorprofile
SELECT * FROM users_consumerprofile

select count(*) from orders_orderproduct

select count(*) from orders_order WHERE created_on >= '2018-01-01'::DATE

SELECT

  	A.id                                                                   AS Id_pedido
	,A.order_id																														 AS id_carrinho
	,A.status                                                              AS Status
	,CASE
		WHEN    A.status = 0   THEN  'Carrinho Abandonado'
		WHEN    A.status = 1   THEN  'Pendente'
		WHEN    A.status = 2   THEN  'Aprovado'
		WHEN    A.status = 3   THEN  'Cancelado/Recusado'
		WHEN    A.status = 4   THEN  'Aprovado'
		WHEN    A.status = 5   THEN  'Cancelado/Recusado'
		WHEN    A.status = 6   THEN  'Cancelado/Recusado'
		WHEN    A.status = 7   THEN  'Aprovado'
		WHEN    A.status = 8   THEN  'Aprovado'
		WHEN    A.status = 9   THEN  'Pendente'
		WHEN    A.status = 10   THEN  'Pendente' -- Alterei o 10 para 'Pendente' em vez de 'Indefinido'
		WHEN    A.status = 11   THEN  'Pendente'
		WHEN    A.status = 12   THEN  'Pendente'
		WHEN    A.status = 13   THEN  'Pendente' -- Estava em Aprovado mudou para 'Pendente'
		WHEN    A.status = 14   THEN  'Aprovado'
		WHEN    A.status = 15   THEN  'Pendente' -- foram incluídos o 15 e 16 a 21/11/18
		WHEN	A.status = 16   THEN  'Pendente'
		ELSE  NULL
		END                                                                 Desc_Status
	,B.user_id                                                             AS Id_Cliente
	,A.distributor_id                                                      AS Id_Distribuidor
  ,G.id																																	AS id_sku
  ,C.product_id																													AS id_produto
	,UPPER(TRIM(CASE
      WHEN CONCAT(G.name,' ',G.type,' ',G.packaging,' ',G.weight_qty, ' - ',G.brand) = '    - '
      THEN CONCAT(C.sku_name,' - ',C.brand)
      ELSE CONCAT(G.name,' ',G.type,' ',G.packaging,' ',G.weight_qty, ' - ',G.brand)
    END))																	AS Produto
	,to_char(B.created_on, 'YYYYMM')                                        AS AnoMes_Carrinho
  ,B.created_on                                    												AS Data_Carrinho
  ,to_char(A.sended_on, 'YYYYMM')                                         AS AnoMes_Status_Pedido
	,A.sended_on                                    												AS Data_Status_Pedido
  ,C.count																																AS Quantidade
	,(C.count*C.stock_price)                                                AS VolumePedidos
	,CASE
		WHEN
		A.status IN (2,4,7,8,14)
		THEN  (C.count*C.stock_price)
		ELSE  NULL
		END                                                                AS VolumeCompras
	,CASE
		WHEN
		A.status IN (1,9,10,11,12,13,15,16) --Acrescentei o 10
		THEN  (C.count*C.stock_price)
		ELSE  NULL
		END                                                                	AS VolumePendente
	,CASE
		WHEN
		A.status IN (3,5,6)
		THEN  (C.count*C.stock_price)
		ELSE  NULL
		END                                                                	AS VolumeCanceladoRecusado
	,UPPER(TRIM(I.description))                                             AS Meio_Pagamento
FROM
         orders_orderstatus                                 A

LEFT JOIN
         orders_order                                       B
         ON A.order_id = B.id

LEFT JOIN
         orders_orderproduct                                C
         ON A.order_id = C.order_id
		AND A.distributor_id = C.distributor_id

LEFT JOIN
         users_consumerprofile                              D
         ON B.user_id = D.user_id

LEFT JOIN
         users_distributorprofile                           E
         ON A.distributor_id = E.user_id

LEFT JOIN
         sku_skuproductsrelation                            F
         ON C.product_id = F.product_id

LEFT JOIN
         sku_sku                                            G
         ON F.sku_id = G.id
LEFT JOIN
			payments_distributorpaymentmethod				H
			ON A.distributor_payment_method_id = H.id
LEFT JOIN
			payments_paymentmethod							I
			ON H.payment_method_id = I.id
WHERE
    --A.status <> 0
    --AND C.product_id IS NOT NULL
    /*AND*/ A.distributor_id not in (123,3002,4767,982,422,761,2)
ORDER BY A.sended_on DESC

SELECT id,name,type,packaging,weight_qty,brand,unit,created_on, photo, published,highlight,category_id,slug FROM sku_sku

SELECT ID,name,updated_at,level,lft,parent_id,rght,tree_id,slug,slug_list FROM category_category

SELECT a.id
      ,CASE WHEN C.name ISNULL AND B.NAME ISNULL
      THEN A.name
      WHEN C.name ISNULL
      THEN B.name
      ELSE C.name
      END                                 nivel0
     ,CASE WHEN B.name ISNULL
      THEN A.name
      ELSE B.name
      END                                 nivel1
     ,A.name                              nivel2
FROM category_category A
LEFT JOIN category_category B
  ON A.parent_id = B.ID
LEFT JOIN category_category C
  ON C.id = B.parent_id
--WHERE C.name IS NOT NULL
ORDER BY nivel0, nivel1

SELECT
    A.id                                                                                    AS User_ID
    ,b.id																																										AS Consumidor_id
    ,b.address_cep																																						AS CEP
	  ,UPPER(TRIM(REPLACE(c.name,'`','''')))                                                  AS Cidade
	  ,c.id                                                                                   AS Cidade_ID
    ,UPPER(TRIM(d.name))                                                                    AS Estado
    ,d.id																																										AS Estado_id
	  ,to_char(a.date_joined ,'YYYYMM')                                                       AS AnoMes_Cadastro
	  ,to_char(a.date_joined ,'DD-MM-YYYY')                                                   AS Data_Cadastro
	  ,to_char(a.last_login   ,'DD-MM-YYYY')                                                  AS Data_Ultimo_Login
    ,to_char(b.birthdate   ,'DD-MM-YYYY') 																									AS Data_Aniversario_PF
    ,CASE
        WHEN   c.name IS NULL
        THEN  0
        ELSE  1
        END                                                                                 AS Cadastro_com_cidade
	  ,CASE
        WHEN    B.cpf IS NOT NULL and c.name IS NOT NULL
        THEN    'PF'
        WHEN    B.cnpj IS NOT NULL and c.name IS NOT NULL
        THEN    'PJ'
        ELSE    NULL
        END                                                                                 AS Tipo

FROM users_user                                                                             A

INNER JOIN users_consumerprofile                                                            B
ON A.id = B.user_id

LEFT JOIN geography_city                                                                    C
ON  B.address_city_id = C.id

LEFT JOIN geography_state                                                                   D
ON  B.address_state_id = D.id

ORDER BY a.date_joined DESC

SELECT
    A.id                                                                                    AS User_ID
    ,B.id																																										as distribuidor_id
    ,b.address_cep																																						AS CEP
	  ,UPPER(TRIM(REPLACE(c.name,'`','''')))                                                  AS Cidade
	  ,c.id                                                                                   AS Cidade_ID
    ,UPPER(TRIM(d.name))                                                                    AS Estado
    ,d.id																																										AS Estado_id
	  ,to_char(a.date_joined ,'YYYYMM')                                                       AS AnoMes_Cadastro
	  ,to_char(a.date_joined ,'DD-MM-YYYY')                                                   AS Data_Cadastro
	  ,to_char(a.last_login   ,'DD-MM-YYYY')                                                  AS Data_Ultimo_Login
    ,b.is_active
    ,b.completed_configuration
    ,CASE
        WHEN   c.name IS NULL
        THEN  0
        ELSE  1
        END                                                                                 AS Cadastro_com_cidade

FROM users_user                                                                             A

INNER JOIN users_distributorprofile                                                          B
ON A.id = B.user_id

LEFT JOIN geography_city                                                                    C
ON  B.address_city_id = C.id

LEFT JOIN geography_state                                                                   D
ON  B.address_state_id = D.id

ORDER BY a.date_joined DESC

SELECT a.id, a.distributorprofile_id, c.name, d.uf FROM users_distributorprofile_cities a
LEFT JOIN geography_city                                                                    C
ON  a.city_id = C.id

LEFT JOIN geography_state                                                                   D
ON  c.state_id = D.id