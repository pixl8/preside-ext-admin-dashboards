/**
 * @feature    admin
 */
component {

	public string function default( event, rc, prc, args={} ) {
		var rendered = [];
		var contexts = ListToArray( args.data ?: "" );

		for ( var context in contexts ) {
			ArrayAppend( rendered, translateResource( uri="enum.adminDashboardContexts:#context#.label", defaultValue=context ) );
		}

		return ArrayToList( rendered, ", " );
	}
}