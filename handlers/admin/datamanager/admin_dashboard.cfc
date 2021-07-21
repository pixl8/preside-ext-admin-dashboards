component extends="preside.system.base.AdminHandler" {

	property name="adminDashboardService" inject="adminDashboardService";
	property name="datamanagerService"    inject="datamanagerService";
	property name="presideObjectService"  inject="presideObjectService";

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
					hasPermission = adminDashboardService.userCanViewDashboard( adminUserId, recordId );
					break;
				case "edit":
					hasPermission = adminDashboardService.userCanEditDashboard( adminUserId, recordId );
					break;
				case "delete":
					hasPermission = adminDashboardService.userCanDeleteDashboard( adminUserId, recordId );
					break;
			}
		}

		if ( !hasPermission && IsTrue( args.throwOnError ?: "" ) ) {
			event.adminAccessDenied();
		}

		return hasPermission;
	}

	private void function preFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var adminUserId     = event.getAdminUserId();
		var adminUserGroups = _getAdminUserGroups( adminUserId );

		args.extraFilters = args.extraFilters ?: [];
		args.extraFilters.append( {
			  filter       = "admin_dashboard.owner = :adminUserId or view_users.id = :adminUserId or view_groups.id in ( :adminUserGroups ) or edit_users.id = :adminUserId or edit_groups.id in ( :adminUserGroups )"
			, filterParams = {
				  adminUserId     = { type="varchar", value=adminUserId }
				, adminUserGroups = { type="varchar", value=adminUserGroups, list=true }
			  }
		} );
	}

	private void function postFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var records         = args.records ?: QueryNew( '' );
		var adminUserId     = event.getAdminUserId();
		var adminUserGroups = _getAdminUserGroups( adminUserId );

		var canView         = [];
		var canEdit         = [];
		var canDelete       = [];
		var canEditThis     = false;

		for( var r in records ){
			canEditThis = r.owner_id == adminUserId || listFind( r.edit_users_list, adminUserId ) || _listFindOneOf( r.edit_groups_list, adminUserGroups );
			canEdit.append( canEditThis );
			canView.append( canEditThis || listFind( r.view_users_list, adminUserId ) || _listFindOneOf( r.view_groups_list, adminUserGroups ) );
			canDelete.append( r.owner_id == adminUserId );
		}

		QueryAddColumn( records, "canView", canView );
		QueryAddColumn( records, "canEdit", canEdit );
		QueryAddColumn( records, "canDelete", canDelete );
	}

	private array function getRecordActionsForGridListing( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var record     = args.record     ?: {};
		var recordId   = record.id       ?: "";

		var actions = [];

		if ( isTrue( record.canView ) ) {
			actions.append( {
				  link       = event.buildAdminLink( objectName=objectName, recordid=recordId )
				, icon       = "fa-eye"
				, class      = ""
				, contextKey = "v"
			} );
		} else {
			actions.append( '<a class="disabled"><i class="fa fa-fw fa-eye light-grey"></i></a>' );
		}
		if ( isTrue( record.canEdit ) ) {
			actions.append( {
				  link       = event.buildAdminLink( objectName=objectName, recordid=recordId, operation="editRecord" )
				, icon       = "fa-pencil"
				, class      = ""
				, contextKey = "e"
			} );
		} else {
			actions.append( '<a class="disabled"><i class="fa fa-fw fa-pencil light-grey"></i></a>' );
		}
		if ( isTrue( record.canView ) ) {
			actions.append( {
				  link       = event.buildAdminLink( objectName=objectName, recordid=recordId, operation="cloneRecord" )
				, icon       = "fa-clone"
				, class      = ""
				, contextKey = "c"
			} );
		} else {
			actions.append( '<a class="disabled"><i class="fa fa-fw fa-clone light-grey"></i></a>' );
		}
		if ( isTrue( record.canDelete ) ) {
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

	private void function extraTopRightButtonsForViewRecord( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var recordId   = prc.recordId    ?: "";
		var record     = prc.record      ?: {};

		args.actions   = args.actions    ?: [];

		if ( !adminDashboardService.userCanEditDashboard( event.getAdminUserId(), recordId ) ) {
			return;
		}

		args.actions.prepend( {
			  link      = event.buildAdminLink( objectName=objectName, operation="sharing", recordId=recordId )
			, btnClass  = "btn-default"
			, iconClass = "fa-users"
			, title     = translateResource( "preside-objects.admin_dashboard:sharing.btn" )
		} );
	}

	public void function sharing() {
		var recordId = rc.id ?: "";

		event.initializeDatamanagerPage(
			  objectName = "admin_dashboard"
			, recordId   = recordId
		);

		if ( !adminDashboardService.userCanEditDashboard( event.getAdminUserId(), recordId ) ) {
			event.accessDenied();
		}

		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard:sharing.breadcrumb.title" )
			, link  = ""
		);

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
		var object           = "admin_dashboard";
		var formName         = "preside-objects.admin_dashboard.sharing";
		var formData         = event.getCollectionForForm( formName );
		var recordId         = rc.id ?: "";
		var validationResult = "";
		var persist          = "";

		if ( !adminDashboardService.userCanEditDashboard( event.getAdminUserId(), recordId ) ) {
			event.accessDenied();
		}

		validationResult = validateForm( formName=formName, formData=formData );

		if ( !validationResult.validated() ) {
			messageBox.error( translateResource( "preside-objects.admin_dashboard:sharing.update.error" ) );
			persist = formData;
			persist.validationResult = validationResult;
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard", recordId=recordId, persistStruct=persist ) );
		}

		getPresideObject( object ).updateData(
			  id                      = recordId
			, data                    = formData
			, updateManyToManyRecords = true
		);

		messageBox.info( translateResource( "preside-objects.admin_dashboard:sharing.update.success" ) );
		setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard", recordId=recordId ) );
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

}
