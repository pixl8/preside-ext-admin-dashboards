component {
	property name="datamanagerService" inject="datamanagerService";

	public string function index( event, rc, prc, args={} ) {
		var objectName = args.object ?: ( args.savedData[ "applies_to" ] ?: "" );

		args.values = [ "" ];
		args.labels = [ "" ];
		args.multiple = true;

		args.remoteUrl = event.buildAdminLink(
			  linkTo      = "ajaxProxy"
			, querystring = "action=admindashboards.widget.DashboardDataFilter.getObjectGridFieldsForAjaxControl"
		);
		args.prefetchUrl = event.buildAdminLink(
			  linkTo      = "ajaxProxy"
			, querystring = "action=admindashboards.widget.DashboardDataFilter.getObjectGridFieldsForAjaxControl"
		);

		return renderView( view="formcontrols/objectPicker/index", args=args );
	}
}