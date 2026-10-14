component extends="preside.system.base.EnhancedDataManagerBase" {

	variables.infoCol1 = [ "isActive", "snapshotMode" ];

	property name="adminDashboardSnapshotService" inject="adminDashboardSnapshotService";

	private void function rootBreadcrumb( event, rc, prc, args={} ) {
		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard:menuTitle" )
			, link  = event.buildAdminLink( objectName="admin_dashboard" )
		);
	}

	private string function _defaultTab( event, rc, prc, args={} ) {
		args.objectName = "admin_dashboard_snapshot";
		args.gridFields = [ "snapshot_date", "status", "record_count", "time_taken", "triggered_by" ];

		return renderView( view="/admin/datamanager/admin_dashboard_snapshot_schema/_snapshotsTab", args=args );
	}

	private boolean function checkPermission( event, rc, prc, args={} ) {
		var hasPerms = super.checkPermission( argumentCollection=arguments );

		return hasPerms && hasCmsPermission( "adminDashboards.manageSnapshots" );
	}

	private string function _infoCardSnapshotMode( event, rc, prc, args={} ) {
		var mode = args.record.snapshot_mode ?: "single";
		var icon = ( mode == "daily" ) ? "fa-calendar blue" : "fa-refresh green";

		return '<i class="fa fa-fw #icon#"></i>&nbsp; ' & renderEnum( mode, "adminDashboardSnapshotMode" );
	}

	private string function _infoCardIsActive( event, rc, prc, args={} ) {
		var isActive = IsBoolean( args.record.is_active ?: "" ) && args.record.is_active;
		var icon     = isActive ? "fa-check-circle green" : "fa-times-circle grey";
		var label    = translateResource( "preside-objects.admin_dashboard_snapshot_schema:infoCard.isActive.#( isActive ? 'active' : 'inactive' )#" );

		return '<i class="fa fa-fw #icon#"></i>&nbsp; ' & label;
	}

	private string function preRenderEditRecordForm( event, rc, prc, args={} ) {
		args.additionalArgs        = args.additionalArgs        ?: {};
		args.additionalArgs.fields = args.additionalArgs.fields ?: {};

		args.additionalArgs.fields.auto_stop_date         = args.additionalArgs.fields.auto_stop_date ?: {};
		args.additionalArgs.fields.auto_stop_date.minDate = DateAdd( "d", 1, Now() );

		return "";
	}

	public void function triggerSnapshotAction( event, rc, prc ) {
		var registrationId = rc.id ?: "";

		if ( !Len( registrationId ) ) {
			messageBox.error( translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.error.noId" ) );
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" ) );
		}

		try {
			adminDashboardSnapshotService.captureSnapshotAsync(
				  registrationId  = registrationId
				, triggeredBy     = "manual"
				, triggeredByUser = event.getAdminUserId()
			);

			messageBox.info( translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.success" ) );
		} catch ( any e ) {
			messageBox.error( translateResource( uri="preside-objects.admin_dashboard_snapshot_schema:trigger.error.capture", data=[ e.message ] ) );
		}

		var returnUrl = rc.returnUrl ?: event.buildAdminLink( objectName="admin_dashboard_snapshot_schema", recordId=registrationId );
		setNextEvent( url=returnUrl );
	}

	private void function extraRecordActionsForGridListing( event, rc, prc, args={} ) {
		args.actions = args.actions ?: [];
		var record   = args.record  ?: {};
		var recordId = record.id    ?: "";

		if ( hasCmsPermission( "adminDashboards.manageSnapshots" ) ) {
			ArrayAppend( args.actions, {
				  link       = event.buildAdminLink(
					  linkTo      = "datamanager.admin_dashboard_snapshot_schema.triggerSnapshotAction"
					, queryString = "id=#recordId#&returnUrl=#UrlEncodedFormat( event.buildAdminLink( objectName='admin_dashboard_snapshot_schema', recordId=recordId ) )#"
				  )
				, icon       = "fa-camera"
				, class      = "confirmation-prompt"
				, title      = translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.btn.confirm" )
				, contextKey = "t"
			} );
		}
	}

	public void function extraTopRightButtonsForViewRecord( event, rc, prc, args={} ) {
		args.actions = args.actions ?: [];
		var recordId = prc.recordId ?: "";

		if ( hasCmsPermission( "adminDashboards.manageSnapshots" ) ) {
			var registration = adminDashboardSnapshotService.getRegistration(
				  registrationId = recordId
				, selectFields   = [ "snapshot_mode" ]
			);

			var snapshotChildren = [
				{
					  link   = event.buildAdminLink(
						  linkTo      = "datamanager.admin_dashboard_snapshot_schema.triggerSnapshotAction"
						, queryString = "id=#recordId#&returnUrl=#UrlEncodedFormat( event.buildAdminLink( objectName='admin_dashboard_snapshot_schema', recordId=recordId ) )#"
					  )
					, icon   = "fa-camera"
					, title  = translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.btn" )
					, prompt = translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.btn.confirm" )
				}
			];

			if ( ( registration.snapshot_mode ?: "single" ) != "single" ) {
				ArrayAppend( snapshotChildren, {
					  link  = event.buildAdminLink(
						  linkTo      = "datamanager.admin_dashboard_snapshot_schema.backfillSnapshots"
						, queryString = "id=#recordId#"
					  )
					, icon  = "fa-history"
					, title = translateResource( "preside-objects.admin_dashboard_snapshot_schema:backfill.btn" )
				} );
			}

			for ( var i = 1; i <= ArrayLen( args.actions ); i++ ) {
				if ( ( args.actions[ i ].iconClass ?: "" ) == "fa-pencil" ) {
					args.actions[ i ].children = snapshotChildren;
					break;
				}
			}
		}
	}

	private void function getExtraListingMultiActions( event, rc, prc, args={} ) {
		args.actions = args.actions ?: [];

		if ( hasCmsPermission( "adminDashboards.manageSnapshots" ) ) {
			ArrayAppend( args.actions, {
				  class     = "btn-warning"
				, label     = translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.btn" )
				, iconClass = "fa-camera"
				, name      = "triggerSnapshot"
				, prompt    = translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.btn.confirm" )
			} );
		}
	}

	private void function multiRecordAction( event, rc, prc, args={} ) {
		var action = args.action ?: "";
		var ids    = args.ids    ?: [];

		if ( action == "triggerSnapshot" ) {
			for ( var registrationId in ids ) {
				adminDashboardSnapshotService.captureSnapshotAsync(
					  registrationId  = registrationId
					, triggeredBy     = "manual"
					, triggeredByUser = event.getAdminUserId()
				);
			}

			messageBox.info( translateResource( uri="preside-objects.admin_dashboard_snapshot_schema:trigger.batch.success", data=[ ArrayLen( ids ) ] ) );
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" ) );
		}
	}

	public void function backfillSnapshots( event, rc, prc ) {
		if ( !hasCmsPermission( "adminDashboards.manageSnapshots" ) ) {
			event.adminAccessDenied();
		}

		var registrationId = rc.id ?: "";
		if ( !Len( registrationId ) ) {
			messageBox.error( translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.error.noId" ) );
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" ) );
		}

		var registration = adminDashboardSnapshotService.getRegistration( registrationId );
		if ( StructIsEmpty( registration ) ) {
			messageBox.error( translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.error.noId" ) );
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" ) );
		}

		if ( ( registration.snapshot_mode ?: "single" ) == "single" ) {
			messageBox.error( translateResource( "preside-objects.admin_dashboard_snapshot_schema:backfill.error.singleMode" ) );
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot_schema", recordId=registrationId ) );
		}

		var regWithOldest = adminDashboardSnapshotService.getRegistration(
			  registrationId = registrationId
			, selectFields   = [ "min( snapshots.snapshot_date ) as oldest_snapshot_date" ]
		);
		var maxEndDate = Now();
		if ( IsDate( regWithOldest.oldest_snapshot_date ?: "" ) ) {
			maxEndDate = DateAdd( "d", -1, regWithOldest.oldest_snapshot_date );
		}

		prc.registrationId = registrationId;
		prc.formName       = "preside-objects.admin_dashboard_snapshot_schema.backfill";
		prc.savedData      = { start_date=( rc.start_date ?: "" ), end_date=( rc.end_date ?: "" ) };
		prc.additionalArgs = { fields={ end_date={ maxDate=maxEndDate }, start_date={ maxDate=maxEndDate } } };
		prc.pageTitle      = translateResource( "preside-objects.admin_dashboard_snapshot_schema:backfill.page.title" );

		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard:menuTitle" )
			, link  = event.buildAdminLink( objectName="admin_dashboard" )
		);
		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard_snapshot_schema:title" )
			, link  = event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" )
		);
		event.addAdminBreadCrumb(
			  title = renderLabel( "admin_dashboard_snapshot_schema", registrationId )
			, link  = event.buildAdminLink( objectName="admin_dashboard_snapshot_schema", recordId=registrationId )
		);
		event.addAdminBreadCrumb(
			  title = prc.pageTitle
			, link  = ""
		);
	}

	public void function backfillSnapshotsAction( event, rc, prc ) {
		if ( !hasCmsPermission( "adminDashboards.manageSnapshots" ) ) {
			event.adminAccessDenied();
		}

		var formData       = event.getCollectionForForm();
		var registrationId = formData.id ?: ( rc.id ?: "" );
		var startDate      = formData.start_date ?: "";
		var endDate        = formData.end_date   ?: "";

		if ( !Len( registrationId ) ) {
			messageBox.error( translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.error.noId" ) );
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" ) );
		}

		var registration = adminDashboardSnapshotService.getRegistration( registrationId );
		if ( StructIsEmpty( registration ) ) {
			messageBox.error( translateResource( "preside-objects.admin_dashboard_snapshot_schema:trigger.error.noId" ) );
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" ) );
		}

		if ( ( registration.snapshot_mode ?: "single" ) == "single" ) {
			messageBox.error( translateResource( "preside-objects.admin_dashboard_snapshot_schema:backfill.error.singleMode" ) );
			setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot_schema", recordId=registrationId ) );
		}

		var validationResult = validateForms();

		if ( !IsDate( startDate ) || ( IsDate( startDate ) && IsDate( endDate ) && ParseDateTime( startDate ) > ParseDateTime( endDate ) ) ) {
			validationResult.addError(
				  fieldName = "start_date"
				, message   = translateResource( "preside-objects.admin_dashboard_snapshot_schema:backfill.error.invalidDates" )
			);
		}

		if ( !IsDate( endDate ) ) {
			validationResult.addError(
				  fieldName = "end_date"
				, message   = translateResource( "preside-objects.admin_dashboard_snapshot_schema:backfill.error.invalidDates" )
			);
		} else {
			if ( ParseDateTime( endDate ) > Now() ) {
				validationResult.addError(
					  fieldName = "end_date"
					, message   = translateResource( "preside-objects.admin_dashboard_snapshot_schema:backfill.error.futureDate" )
				);
			}

			var regWithOldest = adminDashboardSnapshotService.getRegistration(
				  registrationId = registrationId
				, selectFields   = [ "min( snapshots.snapshot_date ) as oldest_snapshot_date" ]
			);
			if ( IsDate( regWithOldest.oldest_snapshot_date ?: "" ) && ParseDateTime( endDate ) >= regWithOldest.oldest_snapshot_date ) {
				validationResult.addError(
					  fieldName = "end_date"
					, message   = translateResource( uri="preside-objects.admin_dashboard_snapshot_schema:backfill.error.overlapDate", data=[ DateFormat( regWithOldest.oldest_snapshot_date, "yyyy-mm-dd" ) ] )
				);
			}
		}

		if ( !validationResult.validated() ) {
			formData.validationResult = validationResult;
			setNextEvent(
				  url           = event.buildAdminLink( linkTo="datamanager.admin_dashboard_snapshot_schema.backfillSnapshots", queryString="id=#registrationId#" )
				, persistStruct = formData
			);
		}

		try {
			var snapshotIds = adminDashboardSnapshotService.backfillSnapshots(
				  registrationId  = registrationId
				, startDate       = ParseDateTime( startDate )
				, endDate         = ParseDateTime( endDate )
				, triggeredByUser = event.getAdminUserId()
			);

			messageBox.info( translateResource( uri="preside-objects.admin_dashboard_snapshot_schema:backfill.success", data=[ ArrayLen( snapshotIds ) ] ) );
		} catch ( any e ) {
			messageBox.error( translateResource( uri="preside-objects.admin_dashboard_snapshot_schema:backfill.error.capture", data=[ e.message ] ) );
		}

		setNextEvent( url=event.buildAdminLink( objectName="admin_dashboard_snapshot_schema", recordId=registrationId ) );
	}

}
