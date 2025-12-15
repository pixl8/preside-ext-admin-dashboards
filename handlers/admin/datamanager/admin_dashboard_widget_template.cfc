component extends="preside.system.base.EnhancedDataManagerBase" {
	variables.infoCardStyle   = "definitionlist";
	variables.infoDescription = "description";
	variables.infoCol1        = [ "is_system", "widget_id" ];
	variables.tabs            = [ "preview" ];

	property name="adminDashboardWidgetService" inject="AdminDashboardWidgetService";

// TABs
	private string function _previewTab( event, rc, prc, args={} ) {
		var templateDetail  = args.record ?: {};
		args.templateConfig = IsJSON( templateDetail.config ?: "" ) ? DeserializeJSON( templateDetail.config ) : {};

		if ( !StructIsEmpty( args.templateConfig ) ) {
			return renderView( view="admin/datamanager/admin_dashboard_widget_template/_preview", args=args );
		}
		return "";
	}

// DATAMANGER CUSTOMIZATIONs
	private boolean function checkPermission( event, rc, prc, args={} ) {
		var checkKeys = [ "edit", "delete" ];
		var recordId  = Trim( prc.recordId ?: "" );
		var permKey   = Trim( args.key     ?: "" );
		var hasPerm   = true;

		if ( Len( recordId ) && ArrayFindNoCase( checkKeys, permKey ) ) {
			hasPerm = !adminDashboardWidgetService.isSystemWidgetTemplate( templateId=recordId );

			if ( !hasPerm ) {
				if ( IsTrue( args.throwOnError ?: "" ) ) {
					event.adminAccessDenied();
				}

				return false;
			}
		}

		return super.checkPermission( argumentCollection=arguments );
	}

	private void function rootBreadcrumb( event, rc, prc, args={} ) {
		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.admin_dashboard:menuTitle" )
			, link  = event.buildAdminLink( objectName="admin_dashboard" )
		);
	}

	private void function extraRecordActionsForGridListing( event, rc, prc, args={} ) {
		var recordId       = Trim( args.record.id ?: "" );
		var isSystemWidget = StructKeyExists( args.record, "is_system" ) ? isTrue( args.record.is_system ) : adminDashboardWidgetService.isSystemWidgetTemplate( templateId=recordId );

		if ( isSystemWidget ) {
			for ( var action in ( args.actions ?: [] ) ) {
				if ( ArrayFindNoCase( [ "e", "d" ], action.contextKey ?: "" ) ) {
					action.link  = "##";
					action.class = "disabled";
				}
			}
		}
	}

	private void function preAddRecordAction( event, rc, prc, args={} ) {
		_validateRecordAction( argumentCollection=arguments );
	}
	private void function preEditRecordAction( event, rc, prc, args={} ) {
		_validateRecordAction( argumentCollection=arguments );
	}
	private void function _validateRecordAction( event, rc, prc, args={} ) {
		args.formData         = args.formData         ?: {};
		args.validationResult = args.validationResult ?: "";

		var widgetConfigString = Trim( args.formData.config ?: "" );

		if ( IsJSON( widgetConfigString ) ) {
			var widgetConfig = DeserializeJSON( widgetConfigString );

			args.formData.widget_id   = args.formData.widget_id ?: ( widgetConfig.widgetId ?: "" );
			args.formData.config_hash = Hash( widgetConfigString );
		} else {
			args.validationResult.addError( fieldName="config", message="preside-objects.admin_dashboard_widget_template:error.config.invalid" );
		}
	}
}