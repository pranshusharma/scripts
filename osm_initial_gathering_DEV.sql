set echo on
spool osm_general_info.log
set serveroutput on
set time on
col INDEX_TYPE for a7
col Last_A for a14
col NAMESPACE_MNEMONIC for a72
col SEGMENT_NAME for a40
col STATUS for a10
col mnemonic for a40
col value for a30
col version for a10
col BUILD_ID for a6
col DEGREE for a6

set lines 160
set pages 100


select mnemonic, value from om_parameter order by 1;

PROMPT ==== Below return PARTITION names
select PARTITION_NAME from user_tab_partitions where TABLE_NAME='OM_ORDER_HEADER' order by 1;

PROMPT ==== Below return CARTRIDGE information

select CARTRIDGE_ID,DEFAULT_VERSION,NAMESPACE_MNEMONIC,VERSION,STATUS,to_char(TIMESTAMP,'yyyy-mm-dd hh24:mi:ss') time_stamp,to_char(LAST_UPDATE,'yyyy-mm-dd hh24:mi:ss')   LAST_UPDATE,(case BUILD_ID WHEN 'NO_BUILD_ID' THEN '-1' ELSE BUILD_ID END) BUILD_ID from om_cartridge order by 5,3,4;

PROMPT ==== Below return orders count in each cartridges
select cartridge_id,count(*) from om_order_header group by cartridge_id order by 1;

PROMPT ==== Below return Order State count in each cartridges
select CARTRIDGE_ID,ORD_STATE_ID,count(*) from om_order_header group by CARTRIDGE_ID,ORD_STATE_ID order by 1,2;

PROMPT ==== Below return live order count in each cartridge
select cartridge_id,count(*) from (select distinct cartridge_id, order_seq_id from om_order_flow) group by cartridge_id order by 1;


PROMPT ==== Below return order count / Order State count in each partition 
declare
    v_sql     varchar2(120) ;
    min_order integer;
    max_order integer;
    v_count   integer;
begin
    for p in
    (select partition_name
    from user_tab_partitions
    where table_name = 'OM_ORDER_HEADER'
    order by partition_name
    )
    loop
        v_sql := 'select min(order_seq_id),max(order_seq_id),count(*) from om_order_header partition('||p.partition_name||')';
        execute immediate v_sql into min_order, max_order, v_count;
        dbms_output.put_line(chr(13) ||chr(10) ||p.partition_name||' min_seq_id: ' || min_order||', max_seq_id: ' || max_order||', count: '
        || v_count) ;
        for r in
        (select distinct ord_state_id,
            count(ord_state_id) as v_count
        from om_order_header
        where order_seq_id between min_order and max_order
        group by ord_state_id
        )
        loop
            dbms_output.put_line(' state :'||r.ord_state_id ||' count:' || r.v_count) ;
        end loop;
    end loop;
end;
/

PROMPT ==== Below return Order ID range by OSM WLS Servers
select * from OM_ORDER_ID_BLOCK order by 1;

PROMPT ==== Below return the time when this script executed
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') executed_at from dual;

PROMPT ==== Below return who executes this script
select user from dual;

PROMPT ==== Below return tablespace and size
select TABLESPACE_NAME,sum(BYTES)/(1024*1024) MB from user_segments group by TABLESPACE_NAME;

PROMPT ==== Below return how large is OSM schema
select sum(bytes)/(1024*1024) MB  from user_segments;

PROMPT ==== Below return smallest and largest Order ID, total Orders
select min(order_seq_id),max(order_seq_id),count(*) from OM_ORDER_HEADER;

PROMPT ==== Below return smallest and largest live Order ID
select min(order_seq_id),max(order_seq_id) from OM_ORDER_FLOW;

PROMPT ==== Below return Order flow COORDINATOR
select min(COORD_SET_ID) from OM_ORDER_FLOW_COORDINATOR;

PROMPT ==== Below return total number of live orders
select count(*) from (select distinct order_seq_id from om_order_flow);

PROMPT ==== Below return, live orders count by TAsk Type
select task_type,count(*) from om_order_flow group by task_type;

PROMPT ==== Below return history of order purging
select * from OM_PURGED_ORDERS order by MIN_ORDER_ID;

PROMPT ==== Below return OSM tables statistics
select TABLE_NAME,NUM_ROWS,BLOCKS,EMPTY_BLOCKS,SAMPLE_SIZE,to_char(LAST_ANALYZED,'yy-mm-dd hh24:mi') Last_A from user_tables order by 1;

PROMPT ==== Below return OSM indexes statistics
select TABLE_NAME,INDEX_NAME,DEGREE,INDEX_TYPE,BLEVEL,LEAF_BLOCKS,DISTINCT_KEYS,NUM_ROWS,SAMPLE_SIZE,to_char(LAST_ANALYZED,'yy-mm-dd hh24:mi') Last_A from user_indexes order by 1,2;

PROMPT ==== Below return OSM tables who have stale statistics
select table_name, partition_name, stale_stats, stattype_locked
   from user_tab_statistics
    where stale_stats='YES'
   order by table_name, partition_name;

PROMPT ==== Below return 
select SEGMENT_NAME,SEGMENT_TYPE,count(1) Count, sum(BYTES)/(1024*1024) MB,sum(BLOCKS) from user_segments where SEGMENT_TYPE like 'TABLE%' or SEGMENT_TYPE like 'INDEX%'  group by SEGMENT_NAME,SEGMENT_TYPE order by 2, 1;



spool off