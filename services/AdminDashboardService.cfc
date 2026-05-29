/**
 * @presideService true
 * @singleton      true
 */
component {
	property name="permissionService"   inject="PermissionService";
	property name="discoverDirectories" inject="presidecms:directories";

// CONSTRUCTOR
	/**
	 *
	 */
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public boolean function isSystemDashboard( required string dashboardId ) {
		return $getPresideObject( "admin_dashboard" ).dataExists( filter={
			  id        = arguments.dashboardId
			, is_system = true
		} );
	}

	public struct function getDashboard(
		  required string dashboardId
		,          array  extraFields = []
	) {
		return $getPresideObject( "admin_dashboard" ).selectData(
			  id                = arguments.dashboardId
			, returntype        = "singleRecordStruct"
			, extraSelectFields = arguments.extraFields
		);
	}

	public query function getSystemDashboards(
		  array   extraFilters = []
		, string  orderBy      = "name"
		, numeric maxRows      = 0
	) {
		return $getPresideObject( "admin_dashboard" ).selectData(
			  filter       = { is_system=true, owner="" }
			, extraFilters = arguments.extraFilters
			, orderBy      = arguments.orderBy
			, maxRows      = arguments.maxRows
		);
	}

	public query function getUserDashboards(
		  string  adminUserId        = $getAdminLoggedInUserId()
		, array   extraFilters       = []
		, string  orderBy            = "name"
		, numeric maxRows            = 0
		, boolean skipNoContextFilter = false
	) {
		_prepareNonSystemDashboardFilter( argumentCollection=arguments );
		if ( !arguments.skipNoContextFilter ) {
			_prepareNoContextDashboardFilter( argumentCollection=arguments );
		}

		return $getPresideObject( "admin_dashboard" ).selectData(
			  filter       = { owner=arguments.adminUserId }
			, extraFilters = arguments.extraFilters
			, orderBy      = arguments.orderBy
			, maxRows      = arguments.maxRows
		);
	}

	public query function getUserAccessibleDashboards(
		  string  adminUserId         = $getAdminLoggedInUserId()
		, array   extraFilters        = []
		, string  orderBy             = "name"
		, numeric maxRows             = 0
		, string  groupBy             = "admin_dashboard.id"
		, boolean skipNoContextFilter = false
	) {
		_prepareNonSystemDashboardFilter( argumentCollection=arguments );
		if ( !arguments.skipNoContextFilter ) {
			_prepareNoContextDashboardFilter( argumentCollection=arguments );
		}

		var adminUserGroups = _getAdminUserGroups( adminUserId=arguments.adminUserId );

		return $getPresideObject( "admin_dashboard" ).selectData(
			  filter = "view_access = 'public'
						OR admin_dashboard.owner = :adminUserId
						OR ( view_access = 'specific' AND ( view_users.id = :adminUserId OR view_groups.id in ( :adminUserGroups ) ) )
						OR ( edit_access = 'specific' AND ( edit_users.id = :adminUserId OR edit_groups.id in ( :adminUserGroups ) ) )"
			, filterParams = {
				  adminUserId     = { type="varchar", value=arguments.adminUserId }
				, adminUserGroups = { type="varchar", value=adminUserGroups, list=true }
			}
			, extraFilters = arguments.extraFilters
			, orderBy      = arguments.orderBy
			, maxRows      = arguments.maxRows
			, groupBy      = arguments.groupBy
		);
	}

	public struct function getDashboardsForSelector(
		  string  adminUserId        = $getAdminLoggedInUserId()
		, struct  contextData        = {}
		, array   extraFilters       = []
		, string  orderBy            = "admin_dashboard.name"
		, numeric maxRows            = 3
		, string  groupBy            = "admin_dashboard.id"
		, string  currentDashboardId = ""
		, boolean includeTemplates   = true
		, boolean includeUser        = true
		, boolean includeAccess      = true
	) {
		var activeDashboard     = {};
		var availableDashboards = [];
		var systemExtraFilters  = Duplicate( arguments.extraFilters );
		var userExtraFilters    = Duplicate( arguments.extraFilters );
		var accessExtraFilters  = Duplicate( arguments.extraFilters );

		if ( Len( arguments.currentDashboardId ) ) {
			activeDashboard = getDashboard( dashboardId=arguments.currentDashboardId, extraFields=[ "name as title" ] );

			var currentDashboardFilter = {
				  filter       = "admin_dashboard.id != :currentDashboardId"
				, filterParams = { currentDashboardId={ type="cf_sql_varchar", value=arguments.currentDashboardId } }
			};

			ArrayAppend( systemExtraFilters, currentDashboardFilter );
			ArrayAppend( userExtraFilters  , currentDashboardFilter );
			ArrayAppend( accessExtraFilters, currentDashboardFilter );
		}

		var context = Trim( arguments.contextData.context ?: "" );
		if ( Len( context ) ) {
			var contextFilter = {
				  filter       = "admin_dashboard.contexts LIKE (:contexts)"
				, filterParams = { contexts={ type="cf_sql_varchar", value="%#context#%" } }
			};

			ArrayAppend( systemExtraFilters, contextFilter );
			ArrayAppend( userExtraFilters  , contextFilter );
			ArrayAppend( accessExtraFilters, contextFilter );
		}

		if ( arguments.includeTemplates ) {
			var systemDashboards = getSystemDashboards( argumentCollection=arguments, extraFilters=systemExtraFilters );
			if ( systemDashboards.recordcount ) {
				var systemDashboardItems = [];

				for ( var dashboard in systemDashboards ) {
					ArrayAppend( systemDashboardItems, {
						  id       = dashboard.id
						, title    = dashboard.name
						, subtitle = $helpers.abbreviate( dashboard.description ?: "", 60 )
						, link     = _buildLinkForDashboard( dashboardId=dashboard.id, contextData=arguments.contextData )
					} );
				}

				if ( ArrayLen( systemDashboardItems ) ) {
					ArrayAppend( availableDashboards, { type="system", items=systemDashboardItems } );
				}
			}
		}

		var hasContext     = Len( context ) > 0;
		var userDashboards = getUserDashboards( argumentCollection=arguments, extraFilters=userExtraFilters, skipNoContextFilter=hasContext );
		if ( userDashboards.recordcount ) {
			var userDashboardItems = [];

			for ( var dashboard in userDashboards ) {
				ArrayAppend( userDashboardItems, {
					  id       = dashboard.id
					, title    = dashboard.name
					, subtitle = $helpers.abbreviate( dashboard.description ?: "", 60 )
					, link     = _buildLinkForDashboard( dashboardId=dashboard.id, contextData=arguments.contextData )
				} );
			}

			if ( arguments.includeUser && ArrayLen( userDashboardItems ) ) {
				ArrayAppend( availableDashboards, { type="currentUser", items=userDashboardItems } );
			}

			ArrayAppend( accessExtraFilters, {
				  filter       = "admin_dashboard.id NOT IN (:excludedDashboardIds)"
				, filterParams = { excludedDashboardIds={ type="cf_sql_varchar", value=ValueList( userDashboards.id ), list=true } }
			} );
		}

		var accessDashboards = getUserAccessibleDashboards( argumentCollection=arguments, extraFilters=accessExtraFilters, skipNoContextFilter=hasContext );
		if ( accessDashboards.recordcount ) {
			var accessDashboardItems = [];

			for ( var dashboard in accessDashboards ) {
				ArrayAppend( accessDashboardItems, {
					  id       = dashboard.id
					, title    = dashboard.name
					, subtitle = $helpers.abbreviate( dashboard.description ?: "", 60 )
					, link     = _buildLinkForDashboard( dashboardId=dashboard.id, contextData=arguments.contextData )
				} );
			}

			if ( arguments.includeAccess && ArrayLen( accessDashboardItems ) ) {
				ArrayAppend( availableDashboards, { type="viewAccess", items=accessDashboardItems } );
			}
		}

		return { activeDashboard=activeDashboard, availableDashboards=availableDashboards };
	}

	public boolean function userCanViewDashboard( required string dashboardId, string adminUserId=$getAdminLoggedInUserId() ) {
		if ( isSystemDashboard( arguments.dashboardId ) || hasFullAccess( arguments.adminUserId ) ) {
			return true;
		}

		var adminUserGroups = _getAdminUserGroups( arguments.adminUserId );

		return $getPresideObject( "admin_dashboard" ).dataExists(
			  filter       = { "admin_dashboard.id"=arguments.dashboardId }
			, extraFilters = [ {
				  filter       = "view_access = 'public'
						or admin_dashboard.owner = :adminUserId
						or ( view_access = 'specific' and ( view_users.id = :adminUserId or view_groups.id in ( :adminUserGroups ) ) )
						or ( edit_access = 'specific' and ( edit_users.id = :adminUserId or edit_groups.id in ( :adminUserGroups ) ) )"
				, filterParams = {
					  adminUserId     = { type="varchar", value=adminUserId }
					, adminUserGroups = { type="varchar", value=adminUserGroups, list=true }
				  }
			  } ]
		);
	}

	public boolean function userCanEditDashboard( required string dashboardId, string adminUserId=$getAdminLoggedInUserId() ) {
		if ( isSystemDashboard( arguments.dashboardId ) ) {
			return false;
		}

		if ( hasFullAccess( arguments.adminUserId ) ) {
			return true;
		}

		return $getPresideObject( "admin_dashboard" ).dataExists(
			  filter       = { "admin_dashboard.id"=arguments.dashboardId }
			, extraFilters = [ {
				  filter       = "admin_dashboard.owner = :adminUserId
						or ( edit_access = 'specific' and ( edit_users.id = :adminUserId or edit_groups$users.id = :adminUserId ) )"
				, filterParams = { adminUserId={ type="varchar", value=arguments.adminUserId } }
			} ]
		);
	}

	public boolean function userCanShareDashboard( required string dashboardId, string adminUserId=$getAdminLoggedInUserId() ) {
		if ( isSystemDashboard( arguments.dashboardId ) ) {
			return false;
		}

		if ( hasFullAccess( arguments.adminUserId ) ) {
			return true;
		}

		return $getPresideObject( "admin_dashboard" ).dataExists(
			filter = { id=arguments.dashboardId, owner=arguments.adminUserId }
		);
	}

	public boolean function userCanDeleteDashboard( required string dashboardId, string adminUserId=$getAdminLoggedInUserId() ) {
		if ( isSystemDashboard( arguments.dashboardId ) ) {
			return false;
		}

		if ( hasFullAccess( arguments.adminUserId ) ) {
			return true;
		}

		return $getPresideObject( "admin_dashboard" ).dataExists(
			filter = { id=arguments.dashboardId, owner=arguments.adminUserId }
		);
	}

	public boolean function hasFullAccess( required string adminUserId ) {
		return permissionService.hasPermission( permissionKey="adminDashboards.fullaccess", userId=arguments.adminUserId );
	}

	public boolean function isDashboardUsingGridLayout( required string dashboardId ) {
		return $getPresideObject( "admin_dashboard" ).dataExists(
			filter = { id=arguments.dashboardId, dashboard_layout="grid" }
		);
	}

	public void function syncSystemDashboards() {
		var coldbox      = $getColdbox();
		var dashboardDao = $getPresideObject( "admin_dashboard" );
		var widgetDao    = $getPresideObject( "admin_dashboard_widget" );
		var handlersPath = "/handlers/admin/adminDashboards/dashboard";
		var i18nBase     = "admin.adminDashboards.dashboard.";
		var dashboardIds = [];

		for ( var dir in discoverDirectories ) {
			dir = ReReplace( dir, "/$", "" );

			var handlers = DirectoryList( dir & handlersPath, false, "query", "*.cfc" );
			for ( var handler in handlers ) {

				if ( handler.type eq "File" ) {
					var dashboardId = ReReplace( handler.name, "\.cfc$", "" );
					var recordId     = dashboardId;

					if ( Len( recordId ) > 32 ) {
						recordId = Left( dashboardId, 24 ) & ListFirst( CreateUUID(), "-" );
					}

					var dashboardExists = dashboardDao.dataExists( filter={ id=recordId, is_system=true } );
					var dashboardData   = {
						  name        = $translateResource( uri="#i18nBase##dashboardId#:title", defaultValue=dashboardId )
						, description = $translateResource( uri="#i18nBase##dashboardId#:description", defaultValue="" )
						, is_system   = true
						, system_id   = dashboardId
						, view_access = "public"
						, owner       = ""
					};

					dashboardData.contexts = _prepareSystemDashboardField( dashboardId, "contexts", dashboardData );
					dashboardData.widgets  = _prepareSystemDashboardField( dashboardId, "widgets", dashboardData );

					if ( IsArray( dashboardData.widgets ) && ArrayLen( dashboardData.widgets ) ) {
						try {
							if ( dashboardExists ) {
								dashboardDao.updateData( id=recordId, data=dashboardData );
							} else {
								dashboardData.id = recordId;

								dashboardDao.insertData( data=dashboardData );
							}

							widgetDao.deleteData( filter={ dashboard=recordId } );

							for ( var widgetData in dashboardData.widgets ) {
								widgetData.dashboard = recordId;

								widgetDao.insertData( data=widgetData );
							}

							ArrayAppend( dashboardIds, recordId );
						} catch ( any e ) {
							$raiseError(e);
						}
					}
				}
			}
		}

		if ( ArrayLen( dashboardIds ) ) {
			dashboardDao.deleteData(
				  filter       = "id NOT IN (:ids) AND is_system = :is_system"
				, filterParams = {
					  ids       = { type="cf_sql_varchar", value=ArrayToList( dashboardIds ), list=true }
					, is_system = true
				}
			);
		}
	}

	public string function buildDashboardViewLink(
		  required string dashboardId
		,          struct contextData = {}
	) {
		return _buildLinkForDashboard( argumentCollection=arguments );
	}

	public string function buildDashboardEditLayoutLink(
		  required string dashboardId
		,          struct contextData = {}
	) {
		var ctx = Trim( arguments.contextData.context ?: "" );

		if ( Len( ctx ) ) {
			var editViewlet = "admin.adminDashboards.context.#ctx#.dashboardEditLayoutLink";

			if ( $getColdbox().viewletExists( editViewlet ) ) {
				var dashboardData             = getDashboard( dashboardId=arguments.dashboardId );
				    dashboardData.contextData = arguments.contextData ?: {};

				var customEditLink = $renderViewlet( event=editViewlet, args=dashboardData );

				if ( IsSimpleValue( customEditLink ) && Len( Trim( customEditLink ) ) ) {
					return Trim( customEditLink );
				}
			}
		}

		return _appendQueryParam(
			  url       = buildDashboardViewLink( dashboardId=arguments.dashboardId, contextData=arguments.contextData ?: {} )
			, paramName = "adminDashboardEditLayout"
			, value     = "true"
		);
	}

	public string function buildDashboardShareLink(
		  required string dashboardId
		,          struct contextData = {}
	) {
		var ctx = Trim( arguments.contextData.context ?: "" );

		if ( Len( ctx ) ) {
			var viewlet = "admin.adminDashboards.context.#ctx#.dashboardShareLink";

			if ( $getColdbox().viewletExists( viewlet ) ) {
				var dashboardData             = getDashboard( dashboardId=arguments.dashboardId );
				    dashboardData.contextData = arguments.contextData;

				var customLink = $renderViewlet( event=viewlet, args=dashboardData );

				if ( IsSimpleValue( customLink ) && Len( Trim( customLink ) ) ) {
					return Trim( customLink );
				}
			}
		}

		return $getRequestContext().buildAdminLink( objectName="admin_dashboard", operation="sharing", recordId=arguments.dashboardId );
	}

	public string function buildDashboardEditRecordLink(
		  required string dashboardId
		,          struct contextData = {}
	) {
		var ctx = Trim( arguments.contextData.context ?: "" );

		if ( Len( ctx ) ) {
			var viewlet = "admin.adminDashboards.context.#ctx#.dashboardEditRecordLink";

			if ( $getColdbox().viewletExists( viewlet ) ) {
				var dashboardData             = getDashboard( dashboardId=arguments.dashboardId );
				    dashboardData.contextData = arguments.contextData;

				var customLink = $renderViewlet( event=viewlet, args=dashboardData );

				if ( IsSimpleValue( customLink ) && Len( Trim( customLink ) ) ) {
					return Trim( customLink );
				}
			}
		}

		return $getRequestContext().buildAdminLink( objectName="admin_dashboard", operation="editRecord", recordId=arguments.dashboardId );
	}

	public string function buildDashboardCloneLink(
		  required string dashboardId
		,          struct contextData = {}
	) {
		var ctx = Trim( arguments.contextData.context ?: "" );

		if ( Len( ctx ) ) {
			var viewlet = "admin.adminDashboards.context.#ctx#.dashboardCloneLink";

			if ( $getColdbox().viewletExists( viewlet ) ) {
				var dashboardData             = getDashboard( dashboardId=arguments.dashboardId );
				    dashboardData.contextData = arguments.contextData;

				var customLink = $renderViewlet( event=viewlet, args=dashboardData );

				if ( IsSimpleValue( customLink ) && Len( Trim( customLink ) ) ) {
					return Trim( customLink );
				}
			}
		}

		return $getRequestContext().buildAdminLink( objectName="admin_dashboard", operation="cloneRecord", recordId=arguments.dashboardId );
	}

	public string function buildDashboardDeleteLink(
		  required string dashboardId
		,          struct contextData = {}
	) {
		var ctx = Trim( arguments.contextData.context ?: "" );

		if ( Len( ctx ) ) {
			var viewlet = "admin.adminDashboards.context.#ctx#.dashboardDeleteLink";

			if ( $getColdbox().viewletExists( viewlet ) ) {
				var dashboardData             = getDashboard( dashboardId=arguments.dashboardId );
				    dashboardData.contextData = arguments.contextData;

				var customLink = $renderViewlet( event=viewlet, args=dashboardData );

				if ( IsSimpleValue( customLink ) && Len( Trim( customLink ) ) ) {
					return Trim( customLink );
				}
			}
		}

		return $getRequestContext().buildAdminLink( objectName="admin_dashboard", operation="deleteRecordAction", recordId=arguments.dashboardId );
	}

	public string function getValidatedAdminReturnUrlOrDefault(
		  required string candidateUrl
		, required string defaultUrl
	) {
		var trimmed = Trim( arguments.candidateUrl );

		if ( Len( trimmed ) && isSafeAdminReturnUrl( trimmed ) ) {
			return trimmed;
		}

		return arguments.defaultUrl;
	}

	public boolean function isSafeAdminReturnUrl( required string url ) {
		var path = Trim( arguments.url );

		if ( !Len( path ) ) {
			return false;
		}

		var prefix = _getAdminUrlPathPrefix();

		return Len( prefix ) && Left( path, Len( prefix ) ) == prefix;
	}

// PRIVATE HELPERS
	private string function _getAdminUserGroups( required string adminUserId ) {
		return $getPresideObject( "security_group" ).selectData(
			  filter       = { "users.id"=arguments.adminUserId }
			, selectFields = [ "id" ]
		).valueList( "id" );
	}

	private any function _prepareSystemDashboardField(
		  required string dashboardId
		, required string viewletName
		,          struct viewletArgs  = {}
		,          string defaultvalue = ""
	) {
		var prepared    = arguments.defaultvalue;
		var fullViewlet = "admin.adminDashboards.dashboard.#dashboardId#.#viewletName#";

		if ( $getColdbox().viewletExists( fullViewlet ) ) {
			prepared = $renderViewlet( event=fullViewlet, args=viewletArgs );
		}

		return prepared;
	}

	private array function _prepareNonSystemDashboardFilter( required array extraFilters ) {
		ArrayAppend( arguments.extraFilters, { filter={ is_system=false } } );

		return arguments.extraFilters;
	}

	private array function _prepareNoContextDashboardFilter( required array extraFilters ) {
		ArrayAppend( arguments.extraFilters, { filter={ contexts="" } } );

		return arguments.extraFilters;
	}

	private string function _buildLinkForDashboard(
		  required string dashboardId
		,          struct contextData = {}
	) {
		if ( isSystemDashboard( dashboardId=arguments.dashboardId ) ) {
			var dashboardData             = getDashboard( dashboardId=arguments.dashboardId );
			    dashboardData.contextData = arguments.contextData;

			var customLink = _prepareSystemDashboardField( arguments.dashboardId, "dashboardLink", dashboardData );
			if ( IsSimpleValue( customLink ) && Len( customLink ) ) {
				return customLink;
			}
		} else if ( Len( Trim( arguments.contextData.context ?: "" ) ) ) {
			var fullViewlet                = "admin.adminDashboards.context.#arguments.contextData.context#.dashboardLink";
			var dashboardData             = getDashboard( dashboardId=arguments.dashboardId );
			    dashboardData.contextData = arguments.contextData;

			if ( $getColdbox().viewletExists( fullViewlet ) ) {
				var customLink = $renderViewlet( event=fullViewlet, args=dashboardData );
				if ( IsSimpleValue( customLink ) && Len( customLink ) ) {
					return customLink;
				}
			}
		}

		return $getRequestContext().buildAdminLink( objectName="admin_dashboard", recordId=arguments.dashboardId );
	}

	private string function _appendQueryParam(
		  required string url
		, required string paramName
		, required string value
	) {
		var separator = Find( "?", arguments.url ) ? "&" : "?";

		return arguments.url & separator & arguments.paramName & "=" & UrlEncodedFormat( arguments.value );
	}

	private string function _getAdminUrlPathPrefix() {
		var sample = ListFirst( $getRequestContext().buildAdminLink( linkTo="index" ), "?" );

		while ( Len( sample ) && Right( sample, 1 ) == "/" ) {
			sample = Left( sample, Len( sample ) - 1 );
		}

		if ( ReFind( "/[^/]+$", sample ) ) {
			var stripped = ReReplace( sample, "/[^/]+$", "" );

			return Len( stripped ) ? stripped : sample;
		}

		return sample;
	}

// GETTERS AND SETTERS

}