SELECT	
id_cliente,
d.parent_id,
count(distinct a.id_pedido) 	num_pedidos,
Sum(volumepedidos) 				volumepedidos,
Sum(volumecompras)				volumecompras
FROM VENDAS a
left join sku_sku2 b
	on a.id_sku = b.id
left join category_category c
	ON B.category_id = c.id
left join category_category d
	ON c.parent_id = d.id
WHERE id_sku is not NULL
group by
id_cliente,
d.parent_id

SELECT * FROM category_category ORDER BY ID

SELECT	
id_cliente,
d.parent_id,
count(distinct a.id_pedido) 	num_pedidos,
Sum(volumepedidos) 				volumepedidos,
Sum(volumecompras)				volumecompras
FROM VENDAS a
left join sku_sku2 b
	on a.id_sku = b.id
left join category_category c
	ON B.category_id = c.id
left join category_category d
	ON c.parent_id = d.id
WHERE id_sku is not NULL
group by
id_cliente,
d.parent_id

SELECT * FROM category_category ORDER BY ID

