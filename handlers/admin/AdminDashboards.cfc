component extends="preside.system.base.AdminHandler" {

	property name="widgetService"    inject="adminDashboardWidgetService";
	property name="dashboardService" inject="adminDashboardService";
	property name="siteService"      inject="delayedInjector:siteService";

	public void function renderWidgetContent( event, rc, prc ) {
		var widgetId         = rc.widgetId         ?: "";
		var dashboardId      = rc.dashboardId      ?: "";
		var instanceId       = rc.instanceId       ?: "";
		var configInstanceId = rc.configInstanceId ?: "";

		if ( !widgetService.userCanViewWidget( widgetId ) ) {
			event.adminAccessDenied();
		}

		event.renderData( type="html", data=widgetService.renderWidgetContent(
			  dashboardId      = dashboardId
			, widgetId         = widgetId
			, instanceId       = instanceId
			, configInstanceId = configInstanceId
			, requestData      = rc
		) );
	}

	public void function configModal( event, rc, prc ) {
		var widgetId    = rc.widgetId    ?: "";
		var dashboardId = rc.dashboardId ?: "";
		var instanceId  = rc.configInstanceId  ?: "";

		if ( !widgetService.userCanViewWidget( widgetId ) ) {
			event.adminAccessDenied();
		}
		if ( !widgetService.widgetHasConfigForm( widgetId ) ) {
			event.notFound();
		}

		prc.configForm = widgetService.renderWidgetConfigForm(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
		);

		event.include( "/js/admin/specific/admindashboards/configmodal/" );

		event.setLayout( "adminModalDialog" );
	}

	public void function exportModal( event, rc, prc ) {
		var widgetId    = rc.widgetId         ?: "";
		var dashboardId = rc.dashboardId      ?: "";
		var instanceId  = rc.configInstanceId ?: "";

		if ( !widgetService.userCanViewWidget( widgetId ) ) {
			event.adminAccessDenied();
		}
		if ( !widgetService.widgetHasConfigForm( widgetId ) ) {
			event.notFound();
		}

		prc.config = widgetService.getWidgetConfiguration(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
		);

		prc.config.widgetId = prc.config.widgetId ?: widgetId;

		if ( StructIsEmpty( prc.config ) ) {
			event.notFound();
		}

		event.setLayout( "adminModalDialog" );
	}

	public void function saveWidgetConfig( event, rc, prc ) {
		var widgetId    = rc.widgetId ?: "";
		var dashboardId = rc.dashboardId ?: "";
		var instanceId  = rc.configInstanceId ?: "";

		if ( !widgetService.userCanViewWidget( widgetId ) ) {
			event.adminAccessDenied();
		}
		if ( !widgetService.widgetHasConfigForm( widgetId ) ) {
			event.notFound();
		}

		var formData = event.getCollectionWithoutSystemVars();
		var formName = widgetService.getWidgetConfigFormName(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
		);

		var validationResult = validateForm( formName=formName, formData=formData );
		var interceptData    = {
			  widgetId         = widgetId
			, dashboardId      = dashboardId
			, instanceId       = instanceId
			, formData         = formData
			, validationResult = validationResult
		};

		event.announceInterception( "onValidateWidgetConfigForm", interceptData );

		var validated     = interceptData.validationResult.validated();
		var errorMessages = validated ? {} : interceptData.validationResult.getMessages();
		var success       = true && validated;

		try {
			if ( validated ) {
				widgetService.saveWidgetConfiguration(
					  dashboardId = dashboardId
					, widgetId    = widgetId
					, instanceId  = instanceId
					, requestData = interceptData.formData
					, formName    = formName
				);
			}
		} catch (any e) {
			logError(e);
			success = false;
		}

		event.renderData( data={ success=success, errorMessages=errorMessages }, type="json" );
	}

	private string function renderDashboard( event, rc, prc, args={} ) {
		var renderedWidgets = widgetService.renderDashboard( argumentCollection=args );

		event.include( "/js/admin/specific/admindashboards/" )
		     .include( "/css/admin/specific/admindashboards/" );

		return renderView( view="/admin/admindashboards/_dashboard", args={ widgets=renderedWidgets, dashboardId=args.dashboardId ?: "" } );
	}

	private string function renderUserGeneratedDashboard( event, rc, prc, args={} ) {
		var dashboardId       = args.dashboardId ?: "";
		var allowEditing      = isTrue( args.allowEditing ?: "" );
		var contextData       = args.contextData ?: {};
		var layoutAction      = _resolveDashboardLayoutAction( event, rc, args );
		var includePageHeader = isTrue( args.includePageHeader ?: "" );
		var adminUserId       = event.getAdminUserId();
		var viewLink          = dashboardService.buildDashboardViewLink( dashboardId=dashboardId, contextData=contextData );
		var canCloneDashboard = dashboardService.userCanCloneDashboard( dashboardId, adminUserId );
		var canEditDashboard  = allowEditing && dashboardService.userCanEditDashboard( dashboardId, adminUserId );
		var editLayoutLink    = canEditDashboard ? dashboardService.buildDashboardEditLayoutLink( dashboardId=dashboardId, contextData=contextData ) : "";
		var deleteReturnUrl   = "";

		if ( layoutAction == "editdashboardlayout" ) {
			if ( Len( Trim( contextData.context ?: "" ) ) ) {
				deleteReturnUrl = Len( editLayoutLink ) ? editLayoutLink : viewLink;
			} else {
				deleteReturnUrl = event.buildAdminLink( objectName="admin_dashboard", operation="editdashboardlayout", recordId=dashboardId );
			}
		}

		var dashboard = widgetService.renderUserGeneratedGridDashboard(
			  dashboardId           = dashboardId
			, allowEditing          = allowEditing
			, contextData           = contextData
			, showTempWidgets       = ( layoutAction == "editdashboardlayout" )
			, deleteWidgetReturnUrl = deleteReturnUrl
			, dashboardLayoutAction = layoutAction
		);

		event.include( "/js/admin/specific/admindashboards/" )
		     .include( "/css/admin/specific/admindashboards/" );

		if ( isTrue( dashboard.canEdit ?: "" ) && layoutAction == "editdashboardlayout" ) {
			event.include( "/js/admin/specific/admindashboards/editing/" );
		}

		StructAppend( args, dashboard );

		args.dashboardLayoutAction = layoutAction;
		args.contextData           = contextData;
		args.includePageHeader     = includePageHeader;

		var showInlineToolbar = !StructIsEmpty( contextData ) && allowEditing;

		if ( showInlineToolbar ) {
			args.showInlineDashboardEditToolbar   = true;
			args.inlineToolbarViewLink            = viewLink;
			args.inlineToolbarEditLink            = editLayoutLink;
			args.inlineToolbarSaveLink            = event.buildAdminLink( linkTo="AdminDashboards.saveEditDashboardLayout", queryString="dashboardId=#dashboardId#&returnUrl=#UrlEncodedFormat( viewLink )#" );
			args.inlineToolbarCancelLink          = event.buildAdminLink( linkTo="AdminDashboards.cancelEditDashboardLayout", queryString="dashboardId=#dashboardId#&returnUrl=#UrlEncodedFormat( viewLink )#" );
			args.inlineToolbarHasTempWidgets      = widgetService.hasTempDashboardWidgets( dashboardId=dashboardId );
			args.inlineToolbarPostAddDashboardUrl = layoutAction == "editdashboardlayout" ? editLayoutLink : "";

			args.inlineToolbarCanShareDashboard   = dashboardService.userCanShareDashboard( dashboardId, adminUserId );
			args.inlineToolbarCanEditDashboard    = canEditDashboard;
			args.inlineToolbarCanCloneDashboard   = canCloneDashboard;
			args.inlineToolbarCanDeleteDashboard  = dashboardService.userCanDeleteDashboard( dashboardId, adminUserId );

			args.inlineToolbarShareLink           = args.inlineToolbarCanShareDashboard  ? dashboardService.buildDashboardShareLink( dashboardId=dashboardId, contextData=contextData )      : "";
			args.inlineToolbarEditRecordLink      = args.inlineToolbarCanEditDashboard   ? dashboardService.buildDashboardEditRecordLink( dashboardId=dashboardId, contextData=contextData ) : "";
			args.inlineToolbarCloneLink           = args.inlineToolbarCanCloneDashboard  ? dashboardService.buildDashboardCloneLink( dashboardId=dashboardId, contextData=contextData )      : "";
			args.inlineToolbarDeleteLink          = args.inlineToolbarCanDeleteDashboard ? dashboardService.buildDashboardDeleteLink( dashboardId=dashboardId, contextData=contextData )     : "";
		} else {
			args.showInlineDashboardEditToolbar   = false;
			args.inlineToolbarPostAddDashboardUrl = "";
		}

		var dashboardsForSelector = dashboardService.getDashboardsForSelector(
			  currentDashboardId = dashboardId
			, contextData        = contextData
			, includeTemplates   = isTrue( args.includeTemplatesForSelector ?: false )
			, includeUser        = isTrue( args.includeUserForSelector      ?: true )
			, includeAccess      = isTrue( args.includeAccessForSelector    ?: true )
		);

		prc.activeDashboard        = dashboardsForSelector.activeDashboard     ?: {};
		prc.availableDashboards    = dashboardsForSelector.availableDashboards ?: [];
		prc.showDashboardSelector  = ( layoutAction != "editdashboardlayout" ) && ArrayLen( prc.availableDashboards ) > 0;

		if ( !StructIsEmpty( contextData ) ) {
			args.hasContextData    = true;
			args.nonContextWidgets = ArrayFilter( dashboard.widgets ?: [], function( _widget ) {
				return isFalse( _widget.supportContext ?: "" );
			} );
		}

		return renderView( view="/admin/admindashboards/layoutGrid/_userGenerated", args=args );
	}

	private string function renderDashboardHeader( event, rc, prc, args={} ) {
		var includeHeader = isTrue( args.includePageHeader ?: ( prc.includePageHeader ?: false ) );
		if ( !includeHeader ) {
			return "";
		}

		return renderView( view="/admin/admindashboards/layoutGrid/_pageTitle", args={
			  title                 = ( prc.pageTitle             ?: "" )
			, subTitle              = ( prc.pageSubTitle          ?: "" )
			, icon                  = ( prc.pageIcon              ?: "" )
			, pageHeaderButtons     = ( prc.pageHeaderButtons     ?: ( args.pageHeaderButtons ?: "" ) )
			, showDashboardSelector = ( prc.showDashboardSelector ?: false )
			, availableDashboards   = ( prc.availableDashboards   ?: [] )
			, activeDashboard       = ( prc.activeDashboard       ?: {} )
		} );
	}

	public void function importDialog( event, rc, prc ) {
		event.setLayout( "adminModalDialog" );
		event.include( "/js/admin/specific/admindashboards/importDialog/" );
		event.setView( view="admin/admindashboards/importDialog" );
	}

	public void function widgetDialog( event, rc, prc ) {
		event.noLayout();
		prc.widgets = _getSortedAndTranslatedAdminWidgets();

		event.setView( view="admin/admindashboards/browserDialog" );
	}

	public array function widgetDialogSearchWidgets( event, rc, prc, args={} ) {
		var searchQuery = Trim( rc.q ?: "" );

		if ( Len( searchQuery ) ) {
			var widgets  = _getSortedAndTranslatedAdminWidgets();
			var filtered = QueryFilter( widgets, function( _widget ) {
				return ( Len( _widget.title ?: "" ) && ReFindNoCase( searchQuery, _widget.title ) )
					|| ( Len( _widget.description ?: "" ) && ReFindNoCase( searchQuery, _widget.description ) );
			} );

			if ( filtered.recordcount ) {
				return ValueArray( filtered, "id" );
			}
		}

		return [];
	}

	public function addWidget( event, rc, prc, args={} ) {
		var templateId  = Trim( rc.templateId ?: "" );
		var dashboardId = Trim( rc.dashboard  ?: "" );
		var widgetId    = Trim( rc.widget     ?: "" );
		var column      = rc.column ?: 1;
		var instanceId  = createUUID();
		var nextSlot    = widgetService.nextWidgetSlot( dashboardId, column );
		var title       = widgetService.getInstanceTitle( dashboardId, widgetId );
		var config      = {};
		var defaultUrl  = event.buildAdminLink( objectName="admin_dashboard", operation="editdashboardlayout", recordId=dashboardId );
		var nextUrl     = dashboardService.getValidatedAdminReturnUrlOrDefault( candidateUrl=rc.returnUrl ?: "", defaultUrl=defaultUrl );

		if ( !_userCanMutateDashboard( event, dashboardId ) ) {
			event.adminAccessDenied();
		}

		if ( Len( templateId ) ) {
			config = widgetService.getSystemWidgetTemplateConfig( templateId=templateId );
		}

		widgetService.addWidget(
			  dashboardId = dashboardId
			, widgetId    = widgetId
			, instanceId  = instanceId
			, column      = column
			, slot        = nextSlot
			, title       = title
			, config      = config
		);

		setNextEvent( url=nextUrl );
	}

	public function deleteWidget( event, rc, prc, args={} ) {
		var dashboardId = args.dashboardId ?: ( rc.dashboardId ?: "" );

		if ( !_userCanMutateDashboard( event, dashboardId ) ) {
			event.adminAccessDenied();
		}

		var instanceId = args.instanceId  ?: ( rc.instanceId  ?: "" );
		var defaultUrl = event.buildAdminLink( objectName="admin_dashboard", recordId=dashboardId );
		var nextUrl    = dashboardService.getValidatedAdminReturnUrlOrDefault( candidateUrl=rc.returnUrl ?: "", defaultUrl=defaultUrl );

		widgetService.deleteWidget(
			  dashboardId = dashboardId
			, instanceId  = instanceId
		);

		setNextEvent( url=nextUrl );
	}

	public function saveEditDashboardLayout( event, rc, prc, args={} ) {
		var dashboardId = args.dashboardId ?: ( rc.dashboardId ?: "" );

		if ( !_userCanMutateDashboard( event, dashboardId ) ) {
			event.adminAccessDenied();
		}

		var defaultUrl = event.buildAdminLink( objectName="admin_dashboard", recordId=dashboardId );
		var nextUrl    = dashboardService.getValidatedAdminReturnUrlOrDefault( candidateUrl=rc.returnUrl ?: "", defaultUrl=defaultUrl );

		widgetService.saveEditDashboardWidgets( dashboardId=dashboardId );

		setNextEvent( url=nextUrl );
	}

	public function cancelEditDashboardLayout( event, rc, prc, args={} ) {
		var dashboardId = args.dashboardId ?: ( rc.dashboardId ?: "" );

		if ( !_userCanMutateDashboard( event, dashboardId ) ) {
			event.adminAccessDenied();
		}

		var defaultUrl = event.buildAdminLink( objectName="admin_dashboard", recordId=dashboardId );
		var nextUrl    = dashboardService.getValidatedAdminReturnUrlOrDefault( candidateUrl=rc.returnUrl ?: "", defaultUrl=defaultUrl );

		widgetService.cancelEditDashboardWidgets( dashboardId=dashboardId );

		setNextEvent( url=nextUrl );
	}

	public string function updateWidgetOrder( event, rc, prc, args={} ) {
		var dashboardId = rc.dashboardId ?: "";

		if ( !_userCanMutateDashboard( event, dashboardId ) ) {
			event.adminAccessDenied();
		}

		var column  = rc.column      ?: 1;
		var widgets = rc.widgets     ?: [];
		var dao     = getPresideObject( "admin_dashboard_widget" );

		widgets.each( function( widget, slot ) {
			dao.updateData(
				  filter = { dashboard=dashboardId, instance_id=widget }
				, data   = { column=column, slot=slot }
			);
		} );

		return "OK";
	}

	public string function updateGridWidgetOrderAndSize( event, rc, prc, args={} ) {
		var dashboardId = rc.dashboardId ?: "";
		var widgets     = rc.widgets     ?: "";
		var isTemporary = rc.isTemporary ?: false;
		var dao         = getPresideObject( "admin_dashboard_widget" );
		var dataField   = isTrue( isTemporary ) ? "dashboard_edit_temp_grid_config" : "grid_config";

		if ( !_userCanMutateDashboard( event, dashboardId ) ) {
			event.adminAccessDenied();
		}

		widgets = deserializeJSON( widgets );

		widgets.each( function( widget, i ) {
			dao.updateData(
				  filter = { dashboard=dashboardId, instance_id=widget.id }
				, data   = { "#dataField#" = serializeJSON( widget.gridConfig ) }
			);
		} );

		return "OK";
	}


// private helpers

	private string function _resolveDashboardLayoutAction( event, rc, prc, args={} ) {
		var fromArgs    = Trim( args.dashboardLayoutAction ?: "" );
		var dashboardId = args.dashboardId ?: ( rc.currentDashboard ?: "" );

		if ( Len( fromArgs ) ) {
			return LCase( fromArgs );
		}

		var evt = LCase( ListLast( rc.event ?: "", "." ) );

		if ( evt == "editdashboardlayout" ) {
			return evt;
		}

		if ( isTrue( rc.adminDashboardEditLayout ?: "" ) &&
			 hasCmsPermission( "adminDashboards.edit" ) &&
			 Len( dashboardId ) &&
			 dashboardService.userCanEditDashboard( dashboardId, event.getAdminUserId() )
		) {
			return "editdashboardlayout";
		}

		if ( evt == "viewrecord" ) {
			return evt;
		}

		return "viewrecord";
	}

	private boolean function _userCanMutateDashboard( event, required string dashboardId ) {
		if ( !Len( Trim( arguments.dashboardId ) ) ) {
			return false;
		}

		if ( !hasCmsPermission( "adminDashboards.edit" ) ) {
			return false;
		}

		if ( dashboardService.isSystemDashboard( arguments.dashboardId ) ) {
			return false;
		}

		return dashboardService.userCanEditDashboard( arguments.dashboardId, event.getAdminUserId() );
	}

	private query function _getSortedAndTranslatedAdminWidgets() {
		// todo, cache this operation (per locale)
		var unsortedOrTranslated         = widgetService.getWidgets();
		var tempArray                    = [];
		var activeSiteTemplate           = isFeatureEnabled( "sites" ) ? siteService.getActiveSiteTemplate() : "";
		var isUserDashboardWidgetHandler = "";
		var isUserDashboardWidget        = false;

		for( var id in unsortedOrTranslated ) {
			var widget = Duplicate( unsortedOrTranslated[ id ] );

			if ( widget.siteTemplates == "*" || ListFindNoCase( widget.siteTemplates, activeSiteTemplate ) ) {
				if ( !widgetService.isEnabled( widget.id ) || !widgetService.isUserDashboardWidget( widget.id ) ) {
					continue;
				}

				widget.title          = translateResource( uri=widget.title      , defaultValue=widget.title );
				widget.description    = translateResource( uri=widget.description, defaultValue="" );
				widget.icon           = translateResource( uri=widget.icon       , defaultValue="fa-magic" );
				widget.group          = translateResource( uri="admin.admindashboards.widget.#id#:group", defaultValue="" );
				widget.isTemplate     = false;
				widget.isSystem       = true;
				widget.supportContext = widgetService.isWidgetSupportContext( widget.id );

				ArrayAppend( tempArray, widget );

				var widgetTemplates = widgetService.getDashboardWidgetTemplates( widgetId=widget.id, widgetConfig=widget );
				if ( ArrayLen( widgetTemplates ) ) {
					ArrayAppend( tempArray, widgetTemplates, true );
				}
			}
		}

		ArraySort( tempArray, function( widget1, widget2 ){
			return widget1.title == widget2.title ? 0 : ( widget1.title > widget2.title ? 1 : -1 );
		} );

		return arrayOfStructsToQuery( "id,title,group,description,icon,isTemplate,recordId,config,supportContext", tempArray );
	}
}