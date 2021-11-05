component {

	private string function owner( event, rc, prc, args={} ) {
		return event.getAdminUserId();
	}

}