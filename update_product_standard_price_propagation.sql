/**
  @author: ivan_porras
  @description: 
*/
CREATE OR REPLACE FUNCTION parse_trigger_updatestandardprice_for() RETURNS trigger AS $$
DECLARE
  r record;
  c CURSOR FOR select  pt.id as idpt,pp.id as idpp,mrp.total_cost from product_template pt inner join product_product pp on pt.default_code = pp.default_code
	        inner join mrp_bom mrp on mrp.product_tmpl_id = pt.id;
BEGIN
  FOR r IN c LOOP
                IF r.total_cost <> (select value_float from ir_property where name = 'standard_price' and (res_id = 'product.product,' || cast(r.idpt as varchar) or res_id = 'product.product,' || cast(r.idpp as varchar)) limit 1)
	THEN
		update ir_property set value_float = r.total_cost where name = 'standard_price' 
		and (res_id = 'product.product,' || cast(r.idpt as varchar) or res_id = 'product.product,' || cast(r.idpp as varchar));
	END IF;
  END LOOP;    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/**
    @author: ivan_porras
*/
CREATE TRIGGER check_update
    BEFORE UPDATE OF total_cost ON mrp_bom
    FOR EACH ROW
    WHEN (OLD.total_cost IS DISTINCT FROM NEW.total_cost)    
    EXECUTE PROCEDURE parse_trigger_updatestandardprice_for();



CREATE OR REPLACE FUNCTION updatestandardprice() RETURNS void AS $$
DECLARE
  r record;
  c CURSOR FOR select  pt.id as idpt,pp.id as idpp,mrp.total_cost from product_template pt inner join product_product pp on pt.default_code = pp.default_code
	        inner join mrp_bom mrp on mrp.product_tmpl_id = pt.id;
BEGIN
  FOR r IN c LOOP
                IF r.total_cost <> (select value_float from ir_property where name = 'standard_price' and (res_id = 'product.product,' || cast(r.idpt as varchar) or res_id = 'product.product,' || cast(r.idpp as varchar)) limit 1)
	THEN
		update ir_property set value_float = r.total_cost where name = 'standard_price' 
		and (res_id = 'product.product,' || cast(r.idpt as varchar) or res_id = 'product.product,' || cast(r.idpp as varchar));
	END IF;
  END LOOP;  
END;
$$ LANGUAGE plpgsql;



select * from updatestandardprice()