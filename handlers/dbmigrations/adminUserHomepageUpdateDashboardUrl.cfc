component {

	private void function run() {
		var dao            = getPresideObject( "security_user_site" );
		var newHomepageUrl = "";

		var toUpdate = dao.selectData(
			  filter       = "homepage_url like :homepage_url"
			, filterParams = { homepage_url="%/admin/datamanager/viewRecord/%object=admin_dashboard%" }
			, selectFields = [ "id", "homepage_url" ]
		);

		for( var row in toUpdate ) {
			newHomepageUrl = ReplaceNoCase( row.homepage_url, "/admin/datamanager/viewRecord/", "/admin/datamanager/admin_dashboard/viewRecord/" );
			newHomepageUrl = ReReplaceNoCase( newHomepageUrl, "object=admin_dashboard&?", "" );

			dao.updateData(
				  id   = row.id
				, data = { homepage_url=newHomepageUrl }
			);
		}
	}

}