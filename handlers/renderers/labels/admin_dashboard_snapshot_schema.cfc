/**
 * @feature adminDashboardSnapshots
 */
component {

	private array function _selectFields( event, rc, prc, args={} ) {
		return [ "record_object", "record_id" ];
	}

	private string function _renderLabel( event, rc, prc, args={} ) {
		var recordObject = arguments.record_object ?: "";
		var recordId     = arguments.record_id     ?: "";

		if ( !Len( recordObject ) || !Len( recordId ) ) {
			return recordObject;
		}

		var objectLabel = translateResource( uri="preside-objects.#recordObject#:title.singular", defaultValue=recordObject );
		var recordLabel = renderLabel( objectName=recordObject, recordId=recordId );

		return objectLabel & ": " & recordLabel;
	}

}