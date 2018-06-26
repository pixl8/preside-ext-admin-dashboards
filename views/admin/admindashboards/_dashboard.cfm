<cfscript>
	widgets = args.widgets ?: "";
</cfscript>

<cfoutput>
	<div class="admin-dashboard-container" data-dashboard-id="#args.dashboardId#">
		<div class="row">#widgets#</div>

		<script type="text/template" class="error-template">
			<p class="alert alert-error">
				<i class="fa fa-fw fa-exclamation-triangle"></i>
				#translateResource( "admindashboards:widget.failed.to.load.message" )#
			</p>
		</script>
	</div>
</cfoutput>