<cfscript>
	icon    = args.icon    ?: "";
	heading = args.heading ?: "";
	items   = args.items   ?: [];
</cfscript>
<cfoutput>
	<h6>
		<cfif Len( icon )><i class="fa #icon#"></i></cfif> #heading#
	</h6>
	<ul>
		<cfloop array="#items#" item="item">
			<li class="dashboard-list-item" >
				<a href="##">
					<span class="dashboard-title">#item.title#</span>
					<cfif Len( item.subtitle ?: "" )><span class="dashboard-subtitle">#item.subtitle#</span></cfif>
				</a>
			</li>
		</cfloop>
	</ul>
</cfoutput>