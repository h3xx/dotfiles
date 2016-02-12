" header for collapsible panels used everywhere in EventCentral

:insert
{if $show_panel|default:true}
{include file="collapsible_panel_header.htm" name=$title|default:'FIXME' style=""}
{/if}

{if $show_panel|default:true}
</div></div>{* /collapsible panel header *}
{/if}
.
