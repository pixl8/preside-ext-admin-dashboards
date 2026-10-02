<cfscript>
	type    = args.type    ?: "";
	heading = args.heading ?: translateResource( uri="admindashboards:selector.group.#type#.label", defaultValue="" );
	icon    = args.icon    ?: translateResource( uri="admindashboards:selector.group.#type#.icon", defaultValue="" );
	items   = args.items   ?: [];
</cfscript>

<cfoutput>
	<cfif ArrayLen( items )>
		<cfif Len( heading )>
			<h6><cfif Len( icon )><i class="fa #icon#"></i></cfif> #heading#</h6>
		</cfif>

		<ul>
			<cfloop array="#items#" item="item">
				<cfset hasLink = Len( item.link ?: "" ) />

				<li class="dashboard-list-item">
					<a class="#hasLink ? "" : "disabled"#" href="#hasLink ? item.link : "##"#">
						<span class="dashboard-title">#item.title#</span>
						<cfif Len( item.subtitle ?: "" )><span class="dashboard-subtitle">#item.subtitle#</span></cfif>
					</a>
				</li>
			</cfloop>
		</ul>
	</cfif>
</cfoutput>