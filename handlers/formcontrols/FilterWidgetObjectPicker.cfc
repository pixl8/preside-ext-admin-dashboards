component {

	public string function index( event, rc, prc, args={} ) {
		args.remoteUrl   = event.buildAdminLink( linkTo="ajaxProxy", querystring="action=admindashboards.widget.DashboardDataFilter.getObjectsForAjaxControl" );
		args.prefetchUrl = event.buildAdminLink( linkTo="ajaxProxy", querystring="action=admindashboards.widget.DashboardDataFilter.getObjectsForAjaxControl" );

		return renderView( view="formcontrols/objectPicker/index", args=args );
	}
}