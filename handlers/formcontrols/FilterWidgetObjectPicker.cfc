component {
	property name="presideObjectService" inject="presideObjectService";

	public string function index( event, rc, prc, args={} ) {
		args.values = [ "" ];
		args.labels = [ "" ];

		var objects = presideObjectService.listObjects();

		for( var object in objects ) {
			if ( !presideObjectService.isPageType( object ) ) {
				args.values.append( object );
				args.labels.append( translateObjectName( object ) );
			}
		}

		return renderView( view="formcontrols/select/index", args=args );
	}
}