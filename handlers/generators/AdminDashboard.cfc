component {

	private string function owner( event, rc, prc, args={} ) {
		var data = args.data ?: {};

		if ( StructKeyExists( data, "owner" ) ) {
			return data.owner;
		}

		return event.getAdminUserId();
	}

}