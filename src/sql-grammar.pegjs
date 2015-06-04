/* Helper Functions */
{
      // Parser utilities
  var _ = require('./sql-parser-util');
}

/* Start Grammar */
start
  = s:( stmt )*
  {
    return {
      'statement': s
    };
  }

/**
 * Expression definition reworked without left recursion for pegjs
 * {@link https://www.sqlite.org/lang_expr.html}
 */
expression "Expression"
  = expressions
  / expression_types

/*
  TODO: Need to fix the grouping of expressions to allow for expressions
        to be logically organized.

  Example: WHERE 1 < 2 AND 3 < 4

           AND                             <
        /         \         versus     /       \
       <           <                  1        AND
    /     \     /     \                      /     \
  1        2   3       4                    2       <
                                                 /     \
                                                3       4
*/
expressions
  = f:( expression_types ) o b:( expression_loop )
  {
    return {
      'type': 'expression',
      'format': 'binary',
      'variant': 'operation',
      'operation': b[0],
      'left': f,
      'right': b[1],
      'modifier': null
    };
  }

expression_loop
  = c:( binary_loop_concat ) o e:( expression )
  { return [c, e]; }

expression_types
  = t:( expression_wrapped / expression_node / expression_value ) o
  { return t; }

expression_wrapped
  = sym_popen o n:( expression_node / expression_value ) o sym_pclose
  { return n; }

expression_value
  = expression_cast
  / expression_exists
  / expression_case
  / expression_raise
  / expression_unary
  / bind_parameter
  / function_call
  / literal_value
  / id_column

expression_unary
  = o:( operator_unary ) o e:( expression )
  {
    return {
      'type': 'expression',
      'format': 'unary',
      'variant': 'logical', // or { 'format': 'unary' }
      'expression': e,
      'modifier': o // TODO: could be { 'operator': o }
    };
  }

expression_cast
  = CAST o sym_popen e:( expression ) o a:( type_alias ) o sym_pclose
  {
    return {
      'type': 'expression',
      'format': 'unary',
      'variant': 'cast',
      'expression': e,
      'modifier': a
    };
  }

type_alias
  = AS e d:( type_definition )
  { return d; }

expression_exists
  = ( n:( NOT e )? x:( EXISTS e ) )? o e:( stmt_select )
  {
    return {
      'type': 'expression',
      'format': 'unary',
      'variant': 'select',
      'expression': e,
      'modifier': _.compose([n, x])
    };
  }

expression_case
  = CASE e e:( expression )? o w:( expression_case_when )+ o s:( expression_case_else )? o END o
  {
    // TODO: Not sure about this
    return {
      'type': 'expression',
      'format': 'binary',
      'variant': 'case',
      'case': e,
      'expression': _.compose([w, s], []),
      'modifier': null
    };
  }


expression_case_when
  = WHEN e w:( expression ) o THEN e t:( expression ) o
  {
    return {
      'type': 'condition',
      'format': 'when',
      'condition': w,
      'expression': t,
      'modifier': null
    };
  }

expression_case_else
  = ELSE e e:( expression ) o
  {
    return {
      'type': 'condition',
      'format': 'else',
      'expression': e,
      'modifier': null
    };
  }

expression_raise
  = RAISE sym_popen o a:( expression_raise_args ) o sym_pclose
  {
    return {
      'type': 'expression',
      'format': 'unary',
      'variant': 'raise',
      'expression': a,
      'modifier': null
    };
  }

expression_raise_args
  = raise_args_ignore
  / raise_args_message

raise_args_ignore
  = f:( IGNORE )
  { return _.textNode(f); }

raise_args_message
  = f:( ROLLBACK / ABORT / FAIL ) o sym_comma o m:( error_message )
  { return _.textNode(f) + ', \'' + m + '\''; }

/* Expression Nodes */
expression_node
  = expression_collate
  / expression_compare
  / expression_null
  / expression_is
  / expression_between
  / expression_in
  / operation_binary

/** @note Removed expression on left-hand-side to remove recursion */
expression_collate
  = v:( expression_value ) o COLLATE e n:( name_collation )
  {
    return {
      'type': 'expression',
      'format': 'unary',
      'variant': 'collate',
      'expression': v,
      'modifier': {
        'type': 'name',
        'name': n // TODO: could also be { 'name': n }
      }
    };
  }

/** @note Removed expression on left-hand-side to remove recursion */
expression_compare
  = v:( expression_value ) o n:( NOT e )? m:( LIKE / GLOB / REGEXP / MATCH ) e e:( expression ) o x:( expression_escape )?
  {
    return {
      'type': 'expression',
      'format': 'binary',
      'variant': 'comparison',
      'comparison': _.compose([n, m]),
      'left': v,
      'right': e,
      'modifier': x
    };
  }

expression_escape
  = ESCAPE e e:( expression )
  {
    return {
      'type': 'expression',
      'format': 'unary',
      'variant': 'escape',
      'expression': e,
      'modifier': null
    };
  }

/** @note Removed expression on left-hand-side to remove recursion */
expression_null
  = v:( expression_value ) o n:( expression_null_nodes )
  {
    return {
      'type': 'expression',
      'format': 'unary',
      'variant': 'null',
      'expression': v,
      'modifier': n
    };
  }

expression_null_nodes
  = i:( IS / NOT ) o n:( NULL ) {
    return _.compose([i, n]);
  }

/** @note Removed expression on left-hand-side to remove recursion */
expression_is
  = v:( expression_value ) o i:( IS e ) n:( NOT e )? e:( expression )
  {
    return {
      'type': 'expression',
      'format': 'binary',
      'variant': 'comparison',
      'comparison': _.compose([i, n]),
      'left': v,
      'right': e,
      'modifier': null
    };
  }

/** @note Removed expression on left-hand-side to remove recursion */
expression_between
  = v:( expression_value ) o n:( NOT e )? b:( BETWEEN e ) e1:( expression ) AND e e2:( expression )
  {
    return {
      'type': 'expression',
      'format': 'binary',
      'variant': 'comparison',
      'comparison': _.compose([n, b]),
      'left': v,
      'right': {
        'type': 'expression',
        'format': 'binary',
        'variant': 'range',
        'left': e1,
        'right': e2,
        'modifier': null
      },
      'modifier': null
    };
  }


/** @note Removed expression on left-hand-side to remove recursion */
expression_in
  = v:( expression_value ) o n:( NOT e )? i:( IN e ) e:( expression_in_target )
  {
    return {
      'type': 'expression',
      'format': 'binary',
      'variant': 'comparison',
      'comparison': _.compose([i, n]),
      'left': v,
      'right': e,
      'modifier': x
    };
  }

expression_in_target
  = expression_list_or_select
  / id_table

expression_list_or_select
  = sym_popen o e:( stmt_select / expression_list ) o sym_pclose
  { return e; }


/**
 * Type definitions
 */
 type_definition "Type Definition"
  = n:( datatype_types ) o a:( type_definition_args )?
  {
    return _.extend({
      'type': 'datatype',
      'format': n[0],
      'affinity': n[1],
      'expression': [] // datatype definition arguments
    }, a);
  }

type_definition_args
  = sym_popen a1:( literal_number_signed ) o a2:( definition_args_loop )? sym_pclose
  {
    return {
      'expression': _.compose([a1, a2], [])
    };
  }

definition_args_loop
  = sym_comma o n:( literal_number_signed ) o
  { return n; }

/**
 * Literal value definition
 * {@link https://www.sqlite.org/syntax/literal-value.html}
 */
literal_value "Literal Value"
  = literal_number
  / literal_string
  / literal_blob
  / literal_null
  / literal_date

literal_null
  = n:( NULL ) o
  {
    return {
      'type': 'literal',
      'variant': 'keyword',
      'value': _.textNode(n)
    };
  }

literal_date
  = d:( CURRENT_DATE / CURRENT_TIMESTAMP / CURRENT_TIME ) o
  {
    return {
      'type': 'literal',
      'variant': 'keyword',
      'value': _.textNode(d)
    };
  }

/**
 * Notes:
 *    1) SQL uses single quotes for string literals.
 *    2) Value is an identier or a string literal based on context.
 * {@link https://www.sqlite.org/lang_keywords.html}
 */
literal_string
  = s:( literal_string_single )
  {
    return {
      'type': 'literal',
      'variant': 'string',
      'value': _.textNode(s)
    };
  }

literal_string_single
  = sym_sglquote s:( literal_string_schar )* sym_sglquote
  {
    /**
      * @note Unescaped the pairs of literal single quotation marks
      */
    return _.unescape(_.textNode(s));
  }

literal_string_schar
  = "''"
  / [^\']

literal_blob
  = [x]i b:( literal_string_single )
  {
    return {
      'type': 'literal',
      'variant': 'blob',
      'value': _.textNode(b)
    };
  }

number_sign
  = s:( sym_plus / sym_minus )
  { return _.textNode(s); }

literal_number_signed
  = s:( number_sign )? n:( literal_number )
  {
    if (_.isOkay(s)) {
      n['value'] = _.compose([s, n['value']]);
    }
    return n;
  }

literal_number
  = literal_number_decimal
  / literal_number_hex

literal_number_decimal
  = d:( number_decimal_node ) e:( number_decimal_exponent )?
  {
    return {
      'type': 'literal',
      'variant': 'decimal',
      'value': _.compose([d, e], '')
    };
  }

number_decimal_node
  = number_decimal_full
  / number_decimal_fraction

number_decimal_full
  = f:( number_digit )+ b:( number_decimal_fraction )?
  { return _.compose([f, b], ''); }

number_decimal_fraction
  = t:( sym_dot ) d:( number_digit )+
  { return _.compose([t, d], ''); }

/* TODO: Not sure about "E"i or just "E" */
number_decimal_exponent
  = e:( "E"i ) s:( [\+\-] )? d:( number_digit )+
  { return _.compose([e, s, d], ''); }

literal_number_hex
  = f:( "0x"i ) b:( number_hex )*
  {
    return {
      'type': 'literal',
      'variant': 'hexidecimal',
      'value': _.compose([f, b], '')
    };
  }

number_hex
  = [0-9a-f]i

number_digit
  = [0-9]

/**
 * Bind Parameters have several syntax variations:
 * 1) "?" ( [0-9]+ )?
 * 2) [\$\@\:] name_char+
 * {@link https://www.sqlite.org/c3ref/bind_parameter_name.html}
 */
bind_parameter "Bind Parameter"
  = bind_parameter_numbered
  / bind_parameter_named
  / bind_parameter_tcl

/**
 * Bind parameters start at index 1 instead of 0.
 */
bind_parameter_numbered
  = q:( sym_quest ) id:( [1-9] [0-9]* )? o
  {
    return {
      'type': 'variable',
      'format': 'numbered',
      'name': _.compose([q, id], '')
    };
  }

bind_parameter_named
  = s:( [\:\@] ) name:( name_char )+ o
  {
    return {
      'type': 'variable',
      'format': 'named',
      'name': _.compose([s, name], '')
    };
  }

bind_parameter_tcl
  = d:( "$" ) name:( name_char / [\:] )+ o suffix:( bind_parameter_named_suffix )?
  {
    return {
      'type': 'variable',
      'format': 'tcl',
      'name': _.compose([_.compose([d, name], ''), suffix])
    };
  }

bind_parameter_named_suffix
  = q1:( sym_dblquote ) n:( !sym_dblquote any )* q2:( sym_dblquote )
  { return _.compose([q1, n, q2], ''); }

/** @note Removed expression on left-hand-side to remove recursion */
/* TODO: Need to refactor this so that expr1 AND expr2 is grouped/associated correctly */
operation_binary
  = v:( expression_value ) o o:( operator_binary ) o e:( expression )
  {
    return {
      'type': 'expression',
      'format': 'binary',
      'variant': 'operation',
      'operation': o,
      'left': v,
      'right': e,
      'modifier': null
    };
  }

binary_loop_concat
  = c:( AND / OR ) o
  { return _.textNode(c); }

expression_list "Expression List"
  = f:( expression ) o rest:( expression_list_rest )*
  {
    return _.compose([f, rest], []);
  }

expression_list_rest
  = sym_comma e:( expression )
  { return e; }

function_call
  = n:( name_function ) sym_popen a:( function_call_args )? sym_pclose
  {
    return _.extend({
      'type': 'function',
      'name': n,
      'distinct': false,
      'expression': []
    }, a);
  }

function_call_args
  = s:( select_star ) {
    return {
      'distinct': false,
      'expression': [{
        'type': 'identifier',
        'variant': 'star',
        'value': s
      }]
    };
  }
  / ( d:( DISTINCT e )? e:( expression_list ) ) {
    return {
      'distinct': _.isOkay(d),
      'expression': e
    };
  }

error_message "Error Message"
  = literal_string

stmt "Statement"
  = stmt_crud
  / stmt_create
  / stmt_drop

stmt_crud
  = w:( clause_with )? o s:( stmt_crud_types )
  {
    return _.extend(s, w);
  }

clause_with "WITH Clause"
  = WITH e r:( RECURSIVE e )? f:( expression_table ) o r:( clause_with_loop )*
  {
    // TODO: final format
    return {
      'type': 'with',
      'recursive': isOkay(r),
      'expression': _.compose([f, r], [])
    };
  }

clause_with_loop
  = sym_comma e:( expression_table )
  { return e; }

/* TODO: This isn't done */
expression_table "Table Expression"
  = n:( name_table ) o a:( sym_popen name_column ( sym_comma name_column )* sym_pclose )? o AS e s:( stmt_select )

stmt_crud_types
  = stmt_select
  / stmt_insert
  / stmt_update
  / stmt_delete

/** {@link https://www.sqlite.org/lang_select.html} */
stmt_select "SELECT Statement"
  = s:( select_loop ) o o:( select_order )? o l:( select_limit )?
  {
    return _.extend(s, {
      'order': o,
      'limit': l
    });
  }

select_order
  = ORDER e BY e d:( select_order_list )
  { return d; }

select_limit
  = LIMIT e e:( expression ) o d:( select_limit_offset )?
  {
    return {
      'start': e,
      'offset': d
    };
  }

select_limit_offset
  = o:( ( OFFSET e ) / sym_comma ) e:( expression )
  { return e; }

select_loop
  = s:( select_parts ) o u:( select_loop_union )*
  {
    if ( _.isOkay(u) ) {
      // TODO: compound query
    }
    return s;
  }

select_loop_union
  = c:( operator_compound ) o s:( select_parts )
  {
    // TODO: compound query
  }

select_parts
  = select_parts_core
  / select_parts_values

select_parts_core
  = s:( select_core_select ) o f:( select_core_from )? o w:( select_core_where )? o g:( select_core_group )? o
  {
    // TODO: Not final syntax!
    return _.extend({
      'type': 'statement',
      'variant': 'select',
      'from': f,
      'where': w,
      'group': g
    }, s);
  }

select_core_select
  = SELECT e d:( DISTINCT / ALL )? o t:( select_target )
  {
    var mod = {};
    if (_.isOkay(d)) {
      mod[_.textNode(d).toLowerCase()] = true;
    }
    return _.extend({
      'result': t,
      'distinct': false,
      'all': false
    }, mod);
  }

select_target
  = f:( select_node ) o r:( select_target_loop )*
  {
    return _.compose([f, r], []);
  }

select_target_loop
  = sym_comma n:( select_node )
  { return n; }

select_core_from
  = FROM e s:( select_source )
  { return s; }

select_core_where
  = WHERE e e:( expression )
  { return _.makeArray(e); }

select_core_group
  = GROUP e BY e e:( expression ) h:( select_core_having )?
  {
    // TODO: format
    return {
      'expression': _.makeArray(e),
      'having': h
    };
  }

select_core_having
  = HAVING e e:( expression )
  { return e; }

select_node
  = select_node_star
  / select_node_aliased

select_node_star
  = q:( select_node_star_qualified )? s:( select_star )
  {
    return {
      'type': 'identifier',
      'variant': 'star',
      'value': _.compose([q, s], '')
    };
  }

select_node_star_qualified
  = n:( name_table ) s:( sym_dot )
  { return _.compose([n, s], ''); }

select_node_aliased
  = e:( expression ) o a:( alias )?
  {
    // TODO: format
    return _.extend(e, {
      'alias': a
    });
  }

select_source
  = select_join_loop
  / select_source_loop

select_source_loop
  = f:( table_or_sub ) t:( source_loop_tail )*
  { return _.compose([f, t], []); }

source_loop_tail
  = sym_comma t:( table_or_sub )
  { return t; }

/* TODO: Need to create rules for second pattern */
table_or_sub
  = table_or_sub_sub
  / table_or_sub_table

table_or_sub_table
  = d:( table_or_sub_table_id ) i:( table_or_sub_index )?
  {
    return _.extend(d, {
      'index': i
    });
  }

table_or_sub_table_id
  = n:( id_table ) o a:( alias )?
  {
    return _.extend(n, {
      'alias': a
    });
  }

table_or_sub_index
  = i:( table_or_sub_index_node )
  {
    return {
      'type': 'index',
      'index': i
    };
  }

table_or_sub_index_node
  = ( INDEXED e BY e n:( name_index ) o ) {
    return _.textNode(n);
  }
  / n:( NOT e INDEXED o ) {
    return _.textNode(n);
  }

table_or_sub_sub
  = sym_popen o l:( select_join_loop / select_source_loop ) o sym_pclose
  { return l; }

alias
  = a:( AS e )? n:( name )
  { return n; }

select_join_loop
  = t:( table_or_sub ) o j:( select_join_clause )+
  {
    // TODO: format
    return {
      'type': 'join',
      'source': t,
      'join': j
    };
  }

select_join_clause
  = o:( join_operator ) o n:( table_or_sub ) o c:( join_condition )?
  {
    // TODO: format
    return _.extend({
      'type': o,
      'source': n,
      'on': null,
      'using': null
    }, c);
  }

join_operator
  = n:( NATURAL e )? o ( t:( ( LEFT ( e OUTER )? ) / INNER / CROSS ) e )? j:( JOIN ) e
  { return _.compose([n, t, j]); }

join_condition
  = c:( join_condition_on / join_condition_using )
  { return c; }

join_condition_on
  = ON e e:( expression )
  {
    return {
      'on': e
    };
  }

/* TODO: should it be name_column or id_column ? */
join_condition_using
  = USING e f:( id_column ) o b:( join_condition_using_loop )*
  {
    return {
      'using': _.compose([f, b], [])
    };
  }

/* TODO: should it be name_column or id_column ? */
join_condition_using_loop
  = sym_comma n:( id_column )
  { return n; }

select_parts_values
  = VALUES o sym_popen l:( expression_list ) o sym_pclose
  {
    // TODO: format
    return {
      'type': 'statement',
      'variant': 'values',
      'values': l
    };
  }

select_order_list
  = f:( select_order_list_item ) o b:( select_order_list_loop )?
  {
    return _.compose([f, b], []);
  }

select_order_list_loop
  = sym_comma i:( select_order_list_item )
  { return i; }

select_order_list_item
  = e:( expression ) o c:( select_order_list_collate )? o d:( select_order_list_dir )?
  {
    // TODO: Not final format
    return {
      'direction': _.textNode(d),
      'expression': e,
      'modifier': c
    };
  }

select_order_list_collate
  = COLLATE e n:( id_collation )
  { return n; }

select_order_list_dir
  = t:( ASC / DESC ) o
  { return _.textNode(t); }

select_star "All Columns"
  = sym_star

/* TODO: Not finished */
operator_compound "Compound Operator"
  = ( UNION ( e ALL )? )
  / INTERSECT
  / EXCEPT

/* Unary and Binary Operators */

operator_unary "Unary Operator"
  = sym_tilde
  / sym_minus
  / sym_plus
  / NOT

/* TODO: Needs return format refactoring */
operator_binary "Binary Operator"
  = o:( binary_concat
  / binary_multiply / binary_mod
  / binary_plus / binary_minus
  / binary_left / binary_right / binary_and / binary_or
  / binary_lt / binary_lte / binary_gt / binary_gte
  / binary_lang / binary_notequal / binary_equal / binary_assign )
  { return _.textNode(o); }

binary_concat "Or"
  = sym_pipe sym_pipe

binary_plus "Add"
  = sym_plus

binary_minus "Subtract"
  = sym_minus

binary_multiply "Multiply"
  = sym_star

binary_mod "Modulo"
  = sym_mod

binary_left "Shift Left"
  = binary_lt binary_lt

binary_right "Shift Right"
  = binary_gt binary_gt

binary_and "Logical AND"
  = sym_amp

binary_or "Logical OR"
  = sym_pipe

binary_lt "Less Than"
  = sym_lt

binary_gt "Greater Than"
  = sym_gt

binary_lte "Less Than Or Equal"
  = binary_lt sym_equal

binary_gte "Greater Than Or Equal"
  = binary_gt sym_equal

binary_assign "Assignment"
  = sym_equal

binary_equal "Equal"
  = binary_assign binary_assign

binary_notequal "Not Equal"
  = ( sym_excl binary_assign )
  / ( binary_lt binary_gt )

binary_lang
  = binary_lang_isnt
  / binary_lang_misc

binary_lang_isnt "IS"
  = i:( IS ) e n:( NOT e )?
  { return _.compose([i, n]); }

binary_lang_misc "Misc Binary Operator"
  = m:( IN / LIKE / GLOB / MATCH / REGEXP ) e
  { return _.textNode(m); }

/* Database, Table and Column IDs */

id_database
  = n:( name_database )
  {
    return {
      'type': 'identifier',
      'variant': 'database',
      'name': n
    };
  }

id_table
  = d:( id_table_qualified )? n:( name_table )
  {
    return {
      'type': 'identifier',
      'variant': 'table',
      'name': _.compose([d, n], '')
    };
  }

id_table_qualified
  = n:( name_database ) d:( sym_dot )
  { return _.compose([n, d], ''); }

id_column
  = d:( id_table_qualified )? t:( id_column_qualified )? n:( name_column )
  {
    return {
      'type': 'identifier',
      'variant': 'column',
      'name': _.compose([d, t, n], '')
    };
  }

id_column_qualified
  = t:( name_table ) d:( sym_dot )
  { return _.compose([t, d], ''); }

id_collation
  = name_collation

/* TODO: FIX all name_* symbols */
name_database "Database Name"
  = name

name_table "Table Name"
  = name

name_column "Column Name"
  = name

name_collation "Collation Name"
  = name

name_index "Index Name"
  = name

name_function "Function Name"
  = name

/* Column datatypes */

datatype_types
  = t:( datatype_text ) { return [t, 'TEXT']; }
  / t:( datatype_real ) { return [t, 'REAL']; }
  / t:( datatype_numeric ) { return [t, 'NUMERIC']; }
  / t:( datatype_integer ) { return [t, 'INTEGER']; }
  / t:( datatype_none ) { return [t, 'NONE']; }

datatype_text
  = t:( ( ( "N"i )? ( "VAR"i )? "CHAR"i )
  / ( ( "TINY"i / "MEDIUM"i / "LONG"i )? "TEXT"i )
  / "CLOB"i )
  { return _.keywordify(t); }

datatype_real
  = t:( ( "DOUBLE"i ( e "PRECISION"i )? )
  / "FLOAT"i
  / "REAL"i )
  { return _.keywordify(t); }

datatype_numeric
  = t:( "NUMERIC"i
  / "DECIMAL"i
  / "BOOLEAN"i
  / ( "DATE"i ( "TIME"i )? )
  / ( "TIME"i ( "STAMP"i )? ) )
  { return _.keywordify(t); }

datatype_integer
  = t:( ( "INT"i ( "2" / "4" / "8" / "EGER"i ) )
  / ( ( "BIG"i / "MEDIUM"i / "SMALL"i / "TINY"i )? "INT"i ) )
  { return _.keywordify(t); }

datatype_none
  = t:( "BLOB"i )
  { return _.keywordify(t); }

/** {@link https://www.sqlite.org/lang_insert.html} */
stmt_insert "INSERT Statement"
  = ( ( INSERT ( OR ( REPLACE / ROLLBACK / ABORT / FAIL / IGNORE ) )? ) / REPLACE )
  ( INTO ( id_table ) ( sym_popen name_column ( sym_comma name_column )* sym_pclose )? )
  insert_parts

/* TODO: LEFT OFF HERE */
insert_parts
  = ( VALUES sym_popen expression_list sym_pclose)
  / ( stmt_select )
  / ( DEFAULT VALUES )

/* TODO: Complete */
stmt_update "UPDATE Statement"
  = any

/* TODO: Complete */
stmt_delete "DELETE Statement"
  = any

/* TODO: Complete */
stmt_create "CREATE Statement"
  = any

/* TODO: Complete */
stmt_drop "DROP Statement"
  = any

/* Naming rules */

/* TODO: Replace me! */
name_char
  = [a-z0-9\-\_]i

name_char_quoted
  = [a-z0-9\-\_ ]i

name
  = name_bracketed
  / name_backticked
  / name_dblquoted
  / name_unquoted

reserved_collect
  = f:( name_char ) rest:( name_char )*
  { return _.compose([f, rest], ''); }

reserved_nodes
  = ( reserved_words / datatype_types ) !name_char

name_unquoted
  = !reserved_nodes n:( name_char+ )
  { return _.textNode(n); }

/** @note Non-standard legacy format */
name_bracketed
  = sym_bopen n:( !sym_bclose name_char_quoted )+ o sym_bclose
  { return _.textNode(n); }

name_dblquoted
  = '"' n:( !'"' name_char_quoted )+ '"'
  { return _.textNode(n); }

/** @note Non-standard legacy format */
name_backticked
  = '`' n:( !'`' name_char_quoted )+ '`'
  { return _.textNode(n); }

/* Symbols */

sym_bopen "Open Bracket"
  = s:( "[" ) o { return _.textNode(s); }
sym_bclose "Close Bracket"
  = s:( "]" ) o { return _.textNode(s); }
sym_popen "Open Parenthesis"
  = s:( "(" ) o { return _.textNode(s); }
sym_pclose "Close Parenthesis"
  = s:( ")" ) o { return _.textNode(s); }
sym_comma "Comma"
  = s:( "," ) o { return _.textNode(s); }
sym_dot "Period"
  = s:( "." ) o { return _.textNode(s); }
sym_star "Asterisk"
  = s:( "*" ) o { return _.textNode(s); }
sym_quest "Question Mark"
  = s:( "?" ) o { return _.textNode(s); }
sym_sglquote "Single Quote"
  = s:( "'" ) o { return _.textNode(s); }
sym_dblquote "Double Quote"
  = s:( '"' ) o { return _.textNode(s); }
sym_backtick "Backtick"
  = s:( "`" ) o { return _.textNode(s); }
sym_tilde "Tilde"
  = s:( "~" ) o { return _.textNode(s); }
sym_plus "Plus"
  = s:( "+" ) o { return _.textNode(s); }
sym_minus "Minus"
  = s:( "-" ) o { return _.textNode(s); }
sym_equal "Equal"
  = s:( "=" ) o { return _.textNode(s); }
sym_amp "Ampersand"
  = s:( "&" ) o { return _.textNode(s); }
sym_pipe "Pipe"
  = s:( "|" ) o { return _.textNode(s); }
sym_mod "Modulo"
  = s:( "%" ) o { return _.textNode(s); }
sym_lt "Less Than"
  = s:( "<" ) o { return _.textNode(s); }
sym_gt "Greater Than"
  = s:( ">" ) o { return _.textNode(s); }
sym_excl "Exclamation"
  = s:( "!" ) o { return _.textNode(s); }

/* Keywords */

ABORT "ABORT Keyword"
  = "ABORT"i
ACTION "ACTION Keyword"
  = "ACTION"i
ADD "ADD Keyword"
  = "ADD"i
AFTER "AFTER Keyword"
  = "AFTER"i
ALL "ALL Keyword"
  = "ALL"i
ALTER "ALTER Keyword"
  = "ALTER"i
ANALYZE "ANALYZE Keyword"
  = "ANALYZE"i
AND "AND Keyword"
  = "AND"i
AS "AS Keyword"
  = "AS"i
ASC "ASC Keyword"
  = "ASC"i
ATTACH "ATTACH Keyword"
  = "ATTACH"i
AUTOINCREMENT "AUTOINCREMENT Keyword"
  = "AUTOINCREMENT"i
BEFORE "BEFORE Keyword"
  = "BEFORE"i
BEGIN "BEGIN Keyword"
  = "BEGIN"i
BETWEEN "BETWEEN Keyword"
  = "BETWEEN"i
BY "BY Keyword"
  = "BY"i
CASCADE "CASCADE Keyword"
  = "CASCADE"i
CASE "CASE Keyword"
  = "CASE"i
CAST "CAST Keyword"
  = "CAST"i
CHECK "CHECK Keyword"
  = "CHECK"i
COLLATE "COLLATE Keyword"
  = "COLLATE"i
COLUMN "COLUMN Keyword"
  = "COLUMN"i
COMMIT "COMMIT Keyword"
  = "COMMIT"i
CONFLICT "CONFLICT Keyword"
  = "CONFLICT"i
CONSTRAINT "CONSTRAINT Keyword"
  = "CONSTRAINT"i
CREATE "CREATE Keyword"
  = "CREATE"i
CROSS "CROSS Keyword"
  = "CROSS"i
CURRENT_DATE "CURRENT_DATE Keyword"
  = "CURRENT_DATE"i
CURRENT_TIME "CURRENT_TIME Keyword"
  = "CURRENT_TIME"i
CURRENT_TIMESTAMP "CURRENT_TIMESTAMP Keyword"
  = "CURRENT_TIMESTAMP"i
DATABASE "DATABASE Keyword"
  = "DATABASE"i
DEFAULT "DEFAULT Keyword"
  = "DEFAULT"i
DEFERRABLE "DEFERRABLE Keyword"
  = "DEFERRABLE"i
DEFERRED "DEFERRED Keyword"
  = "DEFERRED"i
DELETE "DELETE Keyword"
  = "DELETE"i
DESC "DESC Keyword"
  = "DESC"i
DETACH "DETACH Keyword"
  = "DETACH"i
DISTINCT "DISTINCT Keyword"
  = "DISTINCT"i
DROP "DROP Keyword"
  = "DROP"i
EACH "EACH Keyword"
  = "EACH"i
ELSE "ELSE Keyword"
  = "ELSE"i
END "END Keyword"
  = "END"i
ESCAPE "ESCAPE Keyword"
  = "ESCAPE"i
EXCEPT "EXCEPT Keyword"
  = "EXCEPT"i
EXCLUSIVE "EXCLUSIVE Keyword"
  = "EXCLUSIVE"i
EXISTS "EXISTS Keyword"
  = "EXISTS"i
EXPLAIN "EXPLAIN Keyword"
  = "EXPLAIN"i
FAIL "FAIL Keyword"
  = "FAIL"i
FOR "FOR Keyword"
  = "FOR"i
FOREIGN "FOREIGN Keyword"
  = "FOREIGN"i
FROM "FROM Keyword"
  = "FROM"i
FULL "FULL Keyword"
  = "FULL"i
GLOB "GLOB Keyword"
  = "GLOB"i
GROUP "GROUP Keyword"
  = "GROUP"i
HAVING "HAVING Keyword"
  = "HAVING"i
IF "IF Keyword"
  = "IF"i
IGNORE "IGNORE Keyword"
  = "IGNORE"i
IMMEDIATE "IMMEDIATE Keyword"
  = "IMMEDIATE"i
IN "IN Keyword"
  = "IN"i
INDEX "INDEX Keyword"
  = "INDEX"i
INDEXED "INDEXED Keyword"
  = "INDEXED"i
INITIALLY "INITIALLY Keyword"
  = "INITIALLY"i
INNER "INNER Keyword"
  = "INNER"i
INSERT "INSERT Keyword"
  = "INSERT"i
INSTEAD "INSTEAD Keyword"
  = "INSTEAD"i
INTERSECT "INTERSECT Keyword"
  = "INTERSECT"i
INTO "INTO Keyword"
  = "INTO"i
IS "IS Keyword"
  = "IS"i
ISNULL "ISNULL Keyword"
  = "ISNULL"i
JOIN "JOIN Keyword"
  = "JOIN"i
KEY "KEY Keyword"
  = "KEY"i
LEFT "LEFT Keyword"
  = "LEFT"i
LIKE "LIKE Keyword"
  = "LIKE"i
LIMIT "LIMIT Keyword"
  = "LIMIT"i
MATCH "MATCH Keyword"
  = "MATCH"i
NATURAL "NATURAL Keyword"
  = "NATURAL"i
NO "NO Keyword"
  = "NO"i
NOT "NOT Keyword"
  = "NOT"i
NOTNULL "NOTNULL Keyword"
  = "NOTNULL"i
NULL "NULL Keyword"
  = "NULL"i
OF "OF Keyword"
  = "OF"i
OFFSET "OFFSET Keyword"
  = "OFFSET"i
ON "ON Keyword"
  = "ON"i
OR "OR Keyword"
  = "OR"i
ORDER "ORDER Keyword"
  = "ORDER"i
OUTER "OUTER Keyword"
  = "OUTER"i
PLAN "PLAN Keyword"
  = "PLAN"i
PRAGMA "PRAGMA Keyword"
  = "PRAGMA"i
PRIMARY "PRIMARY Keyword"
  = "PRIMARY"i
QUERY "QUERY Keyword"
  = "QUERY"i
RAISE "RAISE Keyword"
  = "RAISE"i
RECURSIVE "RECURSIVE Keyword"
  = "RECURSIVE"i
REFERENCES "REFERENCES Keyword"
  = "REFERENCES"i
REGEXP "REGEXP Keyword"
  = "REGEXP"i
REINDEX "REINDEX Keyword"
  = "REINDEX"i
RELEASE "RELEASE Keyword"
  = "RELEASE"i
RENAME "RENAME Keyword"
  = "RENAME"i
REPLACE "REPLACE Keyword"
  = "REPLACE"i
RESTRICT "RESTRICT Keyword"
  = "RESTRICT"i
RIGHT "RIGHT Keyword"
  = "RIGHT"i
ROLLBACK "ROLLBACK Keyword"
  = "ROLLBACK"i
ROW "ROW Keyword"
  = "ROW"i
SAVEPOINT "SAVEPOINT Keyword"
  = "SAVEPOINT"i
SELECT "SELECT Keyword"
  = "SELECT"i
SET "SET Keyword"
  = "SET"i
TABLE "TABLE Keyword"
  = "TABLE"i
TEMP "TEMP Keyword"
  = "TEMP"i
TEMPORARY "TEMPORARY Keyword"
  = "TEMPORARY"i
THEN "THEN Keyword"
  = "THEN"i
TO "TO Keyword"
  = "TO"i
TRANSACTION "TRANSACTION Keyword"
  = "TRANSACTION"i
TRIGGER "TRIGGER Keyword"
  = "TRIGGER"i
UNION "UNION Keyword"
  = "UNION"i
UNIQUE "UNIQUE Keyword"
  = "UNIQUE"i
UPDATE "UPDATE Keyword"
  = "UPDATE"i
USING "USING Keyword"
  = "USING"i
VACUUM "VACUUM Keyword"
  = "VACUUM"i
VALUES "VALUES Keyword"
  = "VALUES"i
VIEW "VIEW Keyword"
  = "VIEW"i
VIRTUAL "VIRTUAL Keyword"
  = "VIRTUAL"i
WHEN "WHEN Keyword"
  = "WHEN"i
WHERE "WHERE Keyword"
  = "WHERE"i
WITH "WITH Keyword"
  = "WITH"i
WITHOUT "WITHOUT Keyword"
  = "WITHOUT"i

reserved_words
  = r:( ABORT / ACTION / ADD / AFTER / ALL / ALTER / ANALYZE / AND / AS / ASC /
    ATTACH / AUTOINCREMENT / BEFORE / BEGIN / BETWEEN / BY / CASCADE / CASE /
    CAST / CHECK / COLLATE / COLUMN / COMMIT / CONFLICT / CONSTRAINT / CREATE /
    CROSS / CURRENT_DATE / CURRENT_TIME / CURRENT_TIMESTAMP / DATABASE / DEFAULT /
    DEFERRABLE / DEFERRED / DELETE / DESC / DETACH / DISTINCT / DROP / EACH /
    ELSE / END / ESCAPE / EXCEPT / EXCLUSIVE / EXISTS / EXPLAIN / FAIL / FOR /
    FOREIGN / FROM / FULL / GLOB / GROUP / HAVING / IF / IGNORE / IMMEDIATE / IN /
    INDEX / INDEXED / INITIALLY / INNER / INSERT / INSTEAD / INTERSECT / INTO /
    IS / ISNULL / JOIN / KEY / LEFT / LIKE / LIMIT / MATCH / NATURAL / NO / NOT /
    NOTNULL / NULL / OF / OFFSET / ON / OR / ORDER / OUTER / PLAN / PRAGMA /
    PRIMARY / QUERY / RAISE / RECURSIVE / REFERENCES / REGEXP / REINDEX /
    RELEASE / RENAME / REPLACE / RESTRICT / RIGHT / ROLLBACK / ROW / SAVEPOINT /
    SELECT / SET / TABLE / TEMP / TEMPORARY / THEN / TO / TRANSACTION / TRIGGER /
    UNION / UNIQUE / UPDATE / USING / VACUUM / VALUES / VIEW / VIRTUAL / WHEN /
    WHERE / WITH / WITHOUT ) { return _.keywordify(r); }

/* Generic rules */

any "Anything"
  = .

o "Optional Whitespace"
  = _*

e "Enforced Whitespace"
  = _+

_ "Whitespace"
  = [ \f\n\r\t\v]

/* TODO: Everything with this symbol */
_TODO_
  = "TODO" e
