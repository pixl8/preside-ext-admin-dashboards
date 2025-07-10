<cfscript>
	actions         = args.actions         ?: [];
	dropdownActions = args.dropdownActions ?: [];
</cfscript>
<cfoutput>

	<cfif ArrayLen( actions ) >
		<cfloop array="#actions#" item="action" >
			#renderView( view="/admin/datamanager/_topRightButton", args=action )#
		</cfloop>
	</cfif>

	<cfif ArrayLen( dropdownActions ) >
		<div class="btn-group pull-right">
			<button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
				<i class="fa fa-fw fa-ellipsis-v"></i>
			</button>
			<ul class="dropdown-menu">
				<cfloop array="#dropdownActions#" item="action" >
					#renderView( view="/admin/datamanager/_topRightButtonChildItem", args=action )#
				</cfloop>
			</ul>
		</div>
	</cfif>

</cfoutput>