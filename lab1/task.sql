do $$
    declare 
         ntables integer;
         ncolumns integer;
         nidx integer;
         rec record;
         row_count integer;
         table_exists boolean;
    begin

        select count(*)
        into ntables
        from pg_tables
        where schemaname='public';

        select count(*)
        into ncolumns
        from pg_attribute
        where attrelid in (
            select oid from pg_class 
            where relnamespace = (
                select oid from pg_namespace where nspname = 'public'
            )
            and relkind = 'r'
        )
        and attnum > 0 and not attisdropped;

        select count(*)
        into nidx
        from pg_index
        where indrelid in (
            select oid from pg_class 
            where relnamespace = (
                select oid from pg_namespace where nspname = 'public'
            )
        ); 

        raise notice 'количество таблиц в схеме public - %', ntables;
        raise notice 'количество столбцов в схеме public - %', ncolumns;
        raise notice 'количество индексов в схеме public - %', nidx;
        raise notice '';
        raise notice '          таблицы схемы public';
        raise notice '';
        raise notice '  имя               столбцов         строк';
        raise notice '------------------------------------------';
        
    for rec in
        select 
            c.relname as table_name,
            count(a.attname) as column_count
        from
            pg_catalog.pg_class as c
            join pg_catalog.pg_attribute as a on c.oid = a.attrelid
        where
            c.relkind = 'r' and
            a.attnum > 0 and
            not a.attisdropped and
            not c.relname like 'pg_%' and 
            not c.relname like 'sql_%'
        group by
            c.relname
        order by
            c.relname
    loop
        select exists (
            select 1 
            from pg_catalog.pg_tables 
            where schemaname = 'public' and tablename = rec.table_name
        ) into table_exists;

        if table_exists then
            begin
                execute format('select count(*) from %I', rec.table_name) into row_count;
                raise notice '% | % | %', rec.table_name, rec.column_count, row_count;
            exception when others then
                raise notice 'ошибка при подсчете строк в таблице %: %', rec.table_name, sqlerrm;
            end;
        else
            raise notice 'таблица % не существует или недоступна.', rec.table_name;
        end if;
    end loop;

end $$;
