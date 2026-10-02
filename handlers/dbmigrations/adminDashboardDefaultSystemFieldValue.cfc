component {

	private void function run() {
		getPresideObject( "admin_dashboard" ).updateData(
			  filter = "is_system IS NULL"
			, data   = { is_system=false }
		);
	}

}