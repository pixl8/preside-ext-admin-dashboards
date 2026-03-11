component extends="preside.system.base.EnhancedDataManagerBase" {

	property name="dashboardService"     inject="adminDashboardService";
	property name="widgetService"        inject="adminDashboardWidgetService";
	property name="datamanagerService"   inject="datamanagerService";
	property name="presideObjectService" inject="presideObjectService";
	property name="enumService"          inject="enumService";

	variables.sidebarNavigation = true;
	variables.infoCol3          = [];
	variables.tabs              = [ "default" ];

	private boolean function checkPermission( event, rc, prc, args={} ) {
		var adminUserId      = event.getAdminUserId();
		var recordId         = prc.recordId ?: "";
		var objectName       = args.object ?: "";
		var allowedOps       = datamanagerService.getAllowedOperationsForObject( objectName );
		var disallowedOps    = presideObjectService.getObjectAttribute( attributeName="datamanagerDisallowedOperations", objectName=objectName );
		var permissionBase   = "adminDashboards";
		var alwaysDisallowed = ListToArray( ListAppend( disallowedOps, "manageContextPerms" ) );
		var permissionKey    = "adminDashboards.#args.key#";
		var hasPermission    = !alwaysDisallowed.find( args.key )
		                    && allowedOps.find( args.key )
		                    && hasCmsPermission( permissionKey );

		if ( hasPermission && len( recordId ) ) {
			switch( args.key ) {
				case "read":
				case "clone":
					hasPermission = dashboardService.userCanViewDashboard( recordId, adminUserId );
					break;
				case "edit":
					hasPermission = dashboardService.userCanEditDashboard( recordId, adminUserId );
					break;
				case "delete":
					hasPermission = dashboardService.userCanDeleteDashboard( recordId, adminUserId );
					break;
			}
		}

		if ( !hasPermission && IsTrue( args.throwOnError ?: "" ) ) {
			event.adminAccessDenied();
		}

		return hasPermission;
	}

	public void function preRenderListing( event, rc, prc, args={} ) {
		prc.adminSidebarItems = prc.adminSidebarItems ?: [];

		var forSystem = isTrue( rc.systemOnly ?: "" );

		if ( forSystem ) {
			prc.gridFields       = [ "contexts", "name", "description", "datecreated" ];
			prc.hiddenGridFields = prc.hiddenGridFields ?: [];
			ArrayAppend( prc.hiddenGridFields, [ "view_access", "edit_access" ], true );
		}

		var sidebarItems = _getSidebarItems( argumentCollection=arguments );
		if ( ArrayLen( sidebarItems ) ) {
			ArrayAppend( prc.adminSidebarItems, sidebarItems, true );
		}

		prc.adminSidebarHeader = renderView( view="/admin/datamanager/admin_dashboard/_sidebarHeader", args=args );
		prc.pageTitle          = "";
		prc.pageIcon           = "";
	}

	private string function listingViewlet( event, rc, prc, args={} ) {
		var forSystem = isTrue( rc.systemOnly ?: "" );

		if ( forSystem ) {
			args.allRecordsLink       = event.buildAdminLink( objectName="admin_dashboard", queryString="systemOnly=true" );
			args.categoryLinkBase     = event.buildAdminLink( objectName="admin_dashboard", queryString="systemOnly=true&activeCategoryId={activeCategoryId}" );
			args.allListingCategories = enumService.listItems( enum="adminDashboardContexts" );
			args.currentListingView   = runEvent(
				  event          = "admin.dataManager._objectListingViewlet"
				, private        = true
				, prePostExempt  = true
				, eventArguments = { args=args }
			);

			return renderView( view="/admin/datamanager/_listingWithCategories", args=args );
		}

		return super.listingViewlet( argumentCollection=arguments );
	}

	private string function getAdditionalQueryStringForBuildAjaxListingLink( event, rc, prc, args={} ) {
		var qs = [];

		if ( isTrue( rc.systemOnly ?: "" ) ) {
			ArrayAppend( qs, "systemOnly=true" );
		}

		if ( Len( rc.activeCategoryId ?: "" ) ) {
			ArrayAppend( qs, "context=#UrlEncodedFormat( rc.activeCategoryId )#" );
		}

		return ArrayToList( qs, "&" );
	}

	private void function preFetchRecordsForGridListing( event, rc, prc, args={} ) {
		args.extraFilters = args.extraFilters ?: [];

		var systemOnly  = isTrue( rc.systemOnly ?: "" );
		var contextVal  = Trim( rc.context ?: "" );
		var adminUserId = event.getAdminUserId();

		if ( !dashboardService.hasFullAccess( adminUserId ) ) {
			var adminUserGroups = _getAdminUserGroups( adminUserId );

			args.selectFields = args.selectFields ?: [];
			args.extraFilters.append( {
				  filter       = "view_access = 'public'
						or admin_dashboard.owner = :adminUserId
						or ( view_access = 'specific' and ( view_users.id = :adminUserId or view_groups.id in ( :adminUserGroups ) ) )
						or ( edit_access = 'specific' and ( edit_users.id = :adminUserId or edit_groups.id in ( :adminUserGroups ) ) )"
				, filterParams = {
					  adminUserId     = { type="varchar", value=adminUserId }
					, adminUserGroups = { type="varchar", value=adminUserGroups, list=true }
				  }
			} );

			ArrayAppend( args.selectFields, "owner_id"         );
			ArrayAppend( args.selectFields, "view_groups_list" );
			ArrayAppend( args.selectFields, "view_users_list"  );
			ArrayAppend( args.selectFields, "edit_groups_list" );
			ArrayAppend( args.selectFields, "edit_users_list"  );
		}

		if ( systemOnly ) {
			ArrayAppend( args.extraFilters, { filter={ is_system=true } } );
		} else {
			ArrayAppend( args.extraFilters, { filter={ is_system=false } } );
		}

		if ( Len( contextVal ) ) {
			ArrayAppend( args.extraFilters, {
				  filter       = "admin_dashboard.contexts = :context
						or admin_dashboard.contexts like :contextAtStart
						or admin_dashboard.contexts like :contextAtEnd
						or admin_dashboard.contexts like :contextInMiddle"
				, filterParams = {
					  context         = { type="cf_sql_varchar", value=contextVal }
					, contextAtStart = { type="cf_sql_varchar", value="#contextVal#,%" }
					, contextAtEnd   = { type="cf_sql_varchar", value="%,#contextVal#" }
					, contextInMiddle = { type="cf_sql_varchar", value="%,#contextVal#,%" }
				}
			} );
		}
	}

	private void function postFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var records         = args.records ?: QueryNew( '' );
		var adminUserId     = event.getAdminUserId();
		var adminUserGroups = _getAdminUserGroups( adminUserId );

		var canView         = [];
		var canEdit         = [];
		var canShare        = [];
		var canDelete       = [];
		var canClone        = [];
		var canViewThis     = false;
		var canEditThis     = false;
		var isSystem        = false;
		var hasFullAccess   = dashboardService.hasFullAccess( adminUserId );

		for ( var r in records ) {
			canEditThis = ( prc.canEdit ?: false ) && ( r.owner_id == adminUserId || ( r.edit_access == "specific" && ( listFind( r.edit_users_list, adminUserId ) || _listFindOneOf( r.edit_groups_list, adminUserGroups ) ) ) );
			canViewThis = canEditThis || r.view_access == "public" || ( r.view_access == "specific" && ( listFind( r.view_users_list, adminUserId ) || _listFindOneOf( r.view_groups_list, adminUserGroups ) ) );
			isSystem    = isTrue( r.is_system ?: dashboardService.isSystemDashboard( dashboardId=r.id ) );

			ArrayAppend( canEdit  , !isSystem && ( hasFullAccess || canEditThis ) );
			ArrayAppend( canView  , hasFullAccess || canViewThis );
			ArrayAppend( canShare , !isSystem && ( hasFullAccess || r.owner_id == adminUserId ) );
			ArrayAppend( canDelete, !isSystem && ( hasFullAccess || ( ( prc.canDelete ?: false ) && r.owner_id == adminUserId ) ) );
			ArrayAppend( canClone , hasFullAccess || ( ( prc.canClone  ?: false ) && canViewThis ) );

			if ( StructKeyExists( r, "contexts" ) ) {
				QuerySetCell( records, "contexts", renderContent(
					  renderer = "adminDashboardContexts"
					, data     = r.contexts
					, args     = r
				), QueryCurrentRow( records ) );
			}
		}

		QueryAddColumn( records, "canView"  , canView   );
		QueryAddColumn( records, "canEdit"  , canEdit   );
		QueryAddColumn( records, "canShare" , canShare  );
		QueryAddColumn( records, "canDelete", canDelete );
		QueryAddColumn( records, "canClone" , canClone  );

		if ( StructIsEmpty( rc ) ) {
			QueryDeleteColumn( records, "owner_id" );
			QueryDeleteColumn( records, "view_groups_list" );
			QueryDeleteColumn( records, "view_users_list"  );
			QueryDeleteColumn( records, "edit_groups_list" );
			QueryDeleteColumn( records, "edit_users_list"  );
		}
	}

	private array function getRecordActionsForGridListing( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var record     = args.record     ?: {};
		var recordId   = record.id       ?: "";

		var actions = [];

		if ( record.canView ) {
			actions.append( {
				  link       = event.buildAdminLink( objectName=objectName, recordid=recordId )
				, icon       = "fa-eye"
				, class      = ""
				, contextKey = "v"
			} );
		} else {
			actions.append( '<a class="disabled"><i class="fa fa-fw fa-eye light-grey"></i></a>' );
		}
		if ( record.canEdit ) {
			actions.append( {
				  link       = event.buildAdminLink( objectName=objectName, recordid=recordId, operation="editRecord" )
				, icon       = "fa-pencil"
				, class      = ""
				, contextKey = "e"
			} );
		} else {
			actions.append( '<a class="disabled"><i class="fa fa-fw fa-pencil light-grey"></i></a>' );
		}
		if ( record.canClone ) {
			actions.append( {
				  link       = event.buildAdminLink( objectName=objectName, recordid=recordId, operation="cloneRecord" )
				, icon       = "fa-clone"
				, class      = ""
				, contextKey = "c"
			} );
		} else {
			actions.append( '<a class="disabled"><i class="fa fa-fw fa-clone light-grey"></i></a>' );
		}
		if ( record.canDelete ) {
			actions.append( {
				  link       = event.buildAdminLink( objectName=objectName, recordid=recordId, operation="deleteRecordAction" )
				, icon       = "fa-trash-o"
				, class      = "confirmation-prompt"
				, title      = translateResource( uri="cms:datamanager.deleteRecord.prompt", data=[ prc.objectTitle, record.name ] )
				, contextKey = "d"
			} );
		} else {
			actions.append( '<a class="disabled"><i class="fa fa-fw fa-trash-o light-grey"></i></a>' );
		}

		return actions;
	}

	private void function extraTopRightButtonsForObject( event, rc, prc, args={} ) {
		args.actions = args.actions ?: [];

		ArrayPrepend( args.actions, {
			  link      = event.buildAdminLink( objectName="admin_dashboard_widget_template" )
			, btnClass  = "btn-default"
			, iconClass = translateResource( "preside-objects.admin_dashboard_widget_template:iconClass" )
			, title     = translateResource( "preside-objects.admin_dashboard_widget_template:manage.btn" )
		} );
	}

	private void function extraTopRightButtonsForViewRecord( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var recordId   = prc.recordId    ?: "";
		var record     = prc.record      ?: {};
		args.actions   = args.actions    ?: [];

		if ( dashboardService.userCanShareDashboard( recordId, event.getAdminUserId() ) ) {
			args.actions.prepend( {
				  link      = event.buildAdminLink( objectName=objectName, operation="sharing", recordId=recordId )
				, btnClass  = "btn-default"
				, iconClass = "fa-users"
				, title     = translateResource( "preside-objects.admin_dashboard:sharing.btn" )
			} );
		}
	}

	private string function renderSidebarHeader( event, rc, prc, args={} ) {
		var customSidebarItems = _getSidebarItems( argumentCollection=arguments );

		if ( ArrayLen( customSidebarItems ) ) {
			prc.adminSidebarItems = customSidebarItems;
		}

		args.canEditDashboard  = dashboardService.userCanEditDashboard( prc.recordId, event.getAdminUserId() );
		prc.adminSidebarFooter = renderView( view="/admin/datamanager/admin_dashboard/_sidebarFooter", args=args );

		return renderView( view="/admin/datamanager/admin_dashboard/_sidebarHeader", args=args );
	}

	private string function _defaultTab( event, rc, prc, args={} ) {
		prc.pageTitle         = prc.recordLabel ?: prc.pageTitle;
		prc.displayPageHeader = false;
		prc.pageIcon          = "";
		prc.pageSubTitle      = translateResource(
			  uri  = "admindashboards:subtitle.title"
			, data = [
				  DateFormat( prc.record.datecreated, "dd mmm yyyy" )
				, renderLabel( "security_user", prc.record.owner_id )
			]
		);

		args.hasTempWidgets   = args.hasTempWidgets ?: widgetService.hasTempDashboardWidgets( dashboardId=args.recordId ?: prc.recordId );
		prc.pageHeaderButtons = _renderPageHeaderButtons( argumentCollection=arguments );
		args.dashboardAlert   = _renderDashboardAlert( argumentCollection=arguments );

		return renderView( view="/admin/adminDashboards/recordView", args=args );
	}

	private string function _renderDashboardAlert( event, rc, prc, args={} ) {
		var interceptArgs = {
			  objectName     = args.objectName ?: ""
			, recordId       = args.recordId   ?: ""
			, record         = prc.record      ?: {}
			, action         = ListLast( rc.event ?: "", "." )
			, hasTempWidgets = isTrue( args.hasTempWidgets ?: widgetService.hasTempDashboardWidgets( dashboardId=args.recordId ?: prc.recordId ) )

			// Default dashboard alert values
			, alertType         = "alert-warning"
			, headingIcon       = "fa-warning"
			, heading           = translateResource( "admindashboards:actions-list.heading" )
			, alertContent      = "" // Populate in the interceptor
			, isCollapsibleOpen = true
		};

		if ( interceptArgs.hasTempWidgets ) {
			interceptArgs.heading      = translateResource( uri="preside-objects.admin_dashboard:gridlayout.unsaved.alert.heading" );
			interceptArgs.alertContent = translateResource( uri="preside-objects.admin_dashboard:gridlayout.unsaved.alert.content" );
		}

		announceInterception( "preRenderDashboardAlert", interceptArgs );

		return renderView( view="/admin/adminDashboards/_dashboardAlert", args=interceptArgs );
	}

	private string function _renderPageHeaderButtons( event, rc, prc, args={} ) {
		var objectName         = args.objectName ?: "";
		var recordId           = args.recordId   ?: "";
		var action             = ListLast( rc.event ?: "", "." );
		var actionsWithButtons = [ "viewrecord", "editdashboardlayout" ];
		var dropdownActions    = []
		var actions            = []
		var rendered           = "";

		if ( actionsWithButtons.findNoCase( action ) ) {

			if( action == "viewrecord" ) {

				/*
				// Temporarily remove favorite button.
				actions.append( {
					  link      = "##"
					, btnClass  = "btn-favourite is-active" // .is-active to make the star filled
					, iconClass = ""
					, title     = renderView( view="/admin/admindashboards/layoutGrid/icon-star" )
				} );
				*/

				if ( dashboardService.userCanEditDashboard( recordId, event.getAdminUserId() ) ) {
					ArrayAppend( actions, {
						  link      = event.buildAdminLink( objectName=objectName, operation="editdashboardlayout", recordId=recordId )
						, btnClass  = "btn-primary"
						, iconClass = ""
						, title     = translateResource( "preside-objects.admin_dashboard:gridlayout.editlayout.btn" )
					} );
				}

				dropdownActions = customizationService.runCustomization(
					  objectName     = objectName
					, action         = "getTopRightButtonsFor#action#"
					, defaultHandler = "admin.datamanager.getTopRightButtonsFor#action#"
					, args           = args
				);

				customizationService.runCustomization(
					  objectName     = objectName
					, action         = "extraTopRightButtons"
					, args           = { objectName=objectName, action=action, actions=actions }
				);

				// Re-label buttons
				for( var menuAction in dropdownActions ) {

					// Edit Button
					if( menuAction.title == translateResource( uri="cms:datamanager.editRecord.btn" ) ) {
						menuAction.title = translateResource( uri="preside-objects.admin_dashboard:gridlayout.edit.btn" )
					}

					// Clone Button
					if( menuAction.title == translateResource( uri="cms:datamanager.cloneRecord.btn" ) ) {
						menuAction.title = translateResource( uri="preside-objects.admin_dashboard:gridlayout.clone.btn" )
					}

					// Delete Button
					if( menuAction.title == translateResource( uri="cms:datamanager.deleteRecord.btn" ) ) {
						menuAction.title = translateResource( uri="preside-objects.admin_dashboard:gridlayout.delete.btn" )
					}
				}
			}

			if ( action == "editdashboardlayout" ) {
				args.hasTempWidgets   = args.hasTempWidgets ?: widgetService.hasTempDashboardWidgets( dashboardId=recordId );

				ArrayAppend( actions, {
					  link      = event.buildAdminLink( linkto="AdminDashboards.cancelEditDashboardLayout", querystring="dashboardId=#recordId#" )
					, btnClass  = "btn-link"
					, iconClass = ""
					, title     = translateResource( uri="preside-objects.admin_dashboard:gridlayout.cancel.btn" )
					, prompt    = args.hasTempWidgets ? translateResource( uri="preside-objects.admin_dashboard:gridlayout.cancel.confirmation" ) : ""
				} );

				ArrayAppend( actions, {
					  link      = event.buildAdminLink( linkto="AdminDashboards.saveEditDashboardLayout", querystring="dashboardId=#recordId#" )
					, btnClass  = "js-save-layout btn-primary"
					, iconClass = ""
					, title     = translateResource( uri="preside-objects.admin_dashboard:gridlayout.save.btn" )
				} );

				ArrayAppend( actions, {
					  link      = "##"
					, btnClass  = "js-grid-auto-layout btn-grid-autolayout btn-default-invert"
					, iconClass = ""
					, title     = renderView( view="/admin/admindashboards/layoutGrid/icon-grid-sm" )
				} );
			}
		}

		return renderView( view="/admin/admindashboards/layoutGrid/_pageTitleButtons", args={ actions=actions, dropdownActions=dropdownActions } );
	}

	private string function topRightButtons( event, rc, prc, args={} ) {
		var rendered = "";

		if( args.action != "viewRecord" ) {
			rendered = runEvent(
				  event          = "admin.datamanager.topRightButtons"
				, private        = true
				, prePostExempt  = true
				, eventArguments = { args=arguments.args }
			);
		}

		return rendered;
	}

	private void function extraTopRightButtonsForObject( event, rc, prc, args={} ) {
		for ( var action in args.actions ?: [] ) {
			if ( ( action.globalKey ?: "" ) == "a" ) {
				action.title = translateResource( uri="preside-objects.admin_dashboard:create.btn" );
				continue;
			}
		}
	}

	private void function preCloneRecordAction( event, rc, prc, args={} ) {
		args.formData.view_access = "private";
		args.formData.edit_access = "private";
	}

	public void function sharing() {
		var recordId = rc.id ?: "";

		event.initializeDatamanagerPage(
			  objectName = "admin_dashboard"
			, recordId   = recordId
		);

		if ( !dashboardService.userCanShareDashboard( recordId, event.getAdminUserId() ) ) {
			event.adminAccessDenied();
		}

		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard:sharing.breadcrumb.title" )
			, link  = ""
		);
		event.include( "/js/admin/specific/admindashboards/sharing/" );

		prc.savedData    = queryGetRow( prc.record, prc.record.recordcount );
		prc.formName     = "preside-objects.admin_dashboard.sharing";
		prc.pageTitle    = translateResource( "preside-objects.admin_dashboard:sharing.page.title" );
		prc.pageSubTitle = translateResource( "preside-objects.admin_dashboard:sharing.page.subtitle" );
	}

	private string function buildSharingLink( event, rc, prc, args={} ) {
		var qs = "id=#( args.recordId ?: "" )#";

		if ( Len( Trim( args.queryString ?: "" ) ) ) {
			qs &= "&#args.queryString#";
		}

		return event.buildAdminLink( linkto="datamanager.admin_dashboard.sharing", querystring=qs );
	}

	public void function sharingAction( event, rc, prc, args={} ) {
		var recordId = rc.id ?: "";

		if ( !dashboardService.userCanShareDashboard( recordId, event.getAdminUserId() ) ) {
			event.adminAccessDenied();
		}

		if ( ( rc.view_access ?: "" ) != "specific" ) {
			rc.view_groups = "";
			rc.view_users  = "";
		}
		if ( ( rc.edit_access ?: "" ) != "specific" ) {
			rc.edit_groups = "";
			rc.edit_users  = "";
		}

		runEvent(
			  event          = "admin.datamanager._editRecordAction"
			, prepostExempt  = true
			, private        = true
			, eventArguments = {
				  object      = "admin_dashboard"
				, formName    = "preside-objects.admin_dashboard.sharing"
				, errorUrl    = event.buildAdminLink( objectName="admin_dashboard", recordId=recordId, operation="sharing" )
				, successUrl  = event.buildAdminLink( objectName="admin_dashboard", recordId=recordId )
				, audit       = true
				, auditAction = "edit_sharing_options"
			  }
		);
	}

	public void function editDashboardLayout( event, rc, prc ) {
		var objectName = "admin_dashboard"
		var recordId   = rc.id ?: "";

		if ( dashboardService.isSystemDashboard( recordId ) || !dashboardService.userCanEditDashboard( recordId, event.getAdminUserId() ) ) {
			event.adminAccessDenied();
		}

		event.initializeDatamanagerPage( objectName=objectName, recordId=recordId, includeAllFormulaFields=true );

		if ( !isQuery( prc.record ) || !prc.record.recordcount ) {
			messageBox.error( translateResource( uri="cms:datamanager.recordNotFound.error", data=[ prc.objectTitle ?: objectName  ] ) );
			setNextEvent( url=event.buildAdminLink( objectName=objectName ) );
		}

		var record             = QueryRowToStruct( prc.record );
		    record.datecreated = _getNonVersionDateCreated( objectName, recordId );

		var defaultTabMethod = variables.sidebarNavigation ? "_tabWithSidebar" : "_tabs";
		prc.tabs  = customizationService.runCustomization(
			  objectName     = objectName
			, action         = "renderTabs"
			, defaultHandler = "admin.datamanager.#objectName#.#defaultTabMethod#"
			, args           = {
				  objectName = objectName
				, recordId   = prc.recordId
				, record     = record
			  }
		);

		prc.topRightButtons = customizationService.runCustomization(
			  objectName     = objectName
			, action         = "topRightButtons"
			, defaultHandler = "admin.datamanager.topRightButtons"
			, args           = { objectName=objectName, action="viewRecord", record=record, recordId=prc.recordId }
		);

		event.setView( "/admin/datamanager/_viewRecord" );
	}

	private string function buildEditDashboardLayoutLink( event, rc, prc, args={} ) {
		var qs = "id=#( args.recordId ?: "" )#";

		if ( Len( Trim( args.queryString ?: "" ) ) ) {
			qs &= "&#args.queryString#";
		}

		return event.buildAdminLink( linkto="datamanager.admin_dashboard.editdashboardlayout", querystring=qs );
	}

// PRIVATE HELPER METHODS
	private boolean function _listFindOneOf( required string list1, required string list2 ) {
		for( var item in listToArray( arguments.list1 ) ) {
			if ( listFind( arguments.list2, item ) ) {
				return true;
			}
		}
		return false;
	}

	private string function _getAdminUserGroups( required string adminUserId ) {
		return getPresideObject( "security_group" ).selectData(
			  filter       = { "users.id"=arguments.adminUserId }
			, selectFields = [ "id" ]
		).valueList( "id" );
	}

	private array function _getSidebarItems( event, rc, prc, args={} ) {
		var curEvent     = event.getCurrentEvent();
		var curObject    = prc.objectName ?: "";
		var forSystem    = isTrue( rc.systemOnly ?: "" );
		var sidebarItems = [ {
			  active = !forSystem && ( curEvent == "admin.datamanager.object" ) && ( curObject == "admin_dashboard" )
			, title  = translateResource( uri="preside-objects.admin_dashboard:sidenav.all.label" )
			, link   = event.buildAdminLink( objectName="admin_dashboard" )
			, icon   = "fa-tachometer"
		} ];

		prc.hasSystemDashboards = prc.hasSystemDashboards ?: getPresideObject( "admin_dashboard" ).dataExists( filter={ is_system=true, owner="" } );
		if ( isTrue( prc.hasSystemDashboards ) ) {
			ArrayAppend( sidebarItems, {
				  active = forSystem && ( curEvent == "admin.datamanager.object" ) && ( curObject == "admin_dashboard" )
				, title  = translateResource( uri="preside-objects.admin_dashboard:sidenav.systemdashboards.title" )
				, link   = event.buildAdminLink( objectName="admin_dashboard", queryString="systemOnly=true" )
				, icon   = "fa-th-large"
			} );
		}

		var createdByMeDashboards = _getCreatedByMeSidenav( argumentCollection=arguments );
		if ( !StructIsEmpty( createdByMeDashboards ) ) {
			ArrayAppend( sidebarItems, createdByMeDashboards );
		}

		var accessibleDashboards = _getAccessibleDashboardsSidenav( argumentCollection=arguments );
		if ( !StructIsEmpty( accessibleDashboards ) ) {
			ArrayAppend( sidebarItems, accessibleDashboards );
		}

		return sidebarItems;
	}

	private struct function _getCreatedByMeSidenav( event, rc, prc, args={} ) {
		var isViewAction = event.getCurrentAction() == "viewRecord";
		var recordId     = prc.recordId ?: ( args.recordId ?: "" );
		var dashboards   = dashboardService.getUserDashboards( extraFilters=args.dashboardExtraFilters ?: [] );
		var myDashboards = [];
		var hasAnyActive = !isViewAction;

		for ( var dashboard in dashboards ) {
			ArrayAppend( myDashboards, {
				  display = true
				, title   = dashboard.name
				, link    = event.buildAdminLink( objectName="admin_dashboard", recordId=dashboard.id )
				, active  = isViewAction ? ( dashboard.id == recordId ) : false
			} );

			hasAnyActive = hasAnyActive || ( dashboard.id == recordId );
		}

		if ( ArrayLen( myDashboards ) ) {
			prc.adminDashboardSidebarExcludeIds = ValueArray( dashboards, "id" );

			return {
				  display      = true
				, open         = hasAnyActive
				, title        = translateResource( uri="preside-objects.admin_dashboard:sidenav.mydashboards.title" )
				, icon         = translateResource( uri="preside-objects.admin_dashboard:sidenav.mydashboards.iconClass" )
				, link         = ""
				, submenuItems = myDashboards
			};
		}
		return {};
	}

	private struct function _getAccessibleDashboardsSidenav( event, rc, prc, args={} ) {
		var excludedIds  = prc.adminDashboardSidebarExcludeIds ?: [];
		var extraFilters = args.dashboardExtraFilters          ?: [];

		if ( ArrayLen( excludedIds ) ) {
			ArrayAppend( extraFilters, {
				  filter       = "admin_dashboard.id NOT IN (:excludedDashboardIds)"
				, filterParams = { excludedDashboardIds={ type="cf_sql_varchar", value=ArrayToList( excludedIds ), list=true } }
			} );
		}

		var isViewAction         = event.getCurrentAction() == "viewRecord";
		var recordId             = prc.recordId ?: ( args.recordId ?: "" );
		var availableDashboards  = dashboardService.getUserAccessibleDashboards( extraFilters=extraFilters );
		var accessibleDashboards = [];
		var hasAnyActive         = false;

		for ( var dashboard in availableDashboards ) {
			ArrayAppend( accessibleDashboards, {
				  display = true
				, title   = dashboard.name
				, link    = event.buildAdminLink( objectName="admin_dashboard", recordId=dashboard.id )
				, active  = isViewAction ? ( dashboard.id == recordId ) : false
			} );

			hasAnyActive = hasAnyActive || ( dashboard.id == recordId );
		}

		if ( ArrayLen( accessibleDashboards ) ) {
			return {
				  display      = true
				, open         = hasAnyActive
				, title        = translateResource( uri="preside-objects.admin_dashboard:sidenav.accessibledashboards.title" )
				, icon         = translateResource( uri="preside-objects.admin_dashboard:sidenav.accessibledashboards.iconClass" )
				, link         = ""
				, submenuItems = accessibleDashboards
			};
		}
		return {};
	}
}
