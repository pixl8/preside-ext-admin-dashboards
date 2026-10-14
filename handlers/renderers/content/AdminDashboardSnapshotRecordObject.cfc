/**
 * @feature adminDashboardSnapshots
 */
component {

	private string function default( event, rc, prc, args={} ) {
		var objectName = args.data ?: "";

		if ( !Len( objectName ) ) {
			return "";
		}

		return translateResource( uri="preside-objects.#objectName#:title", defaultValue=objectName );
	}

}