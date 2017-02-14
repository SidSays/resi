
.table.tablesorter {
	overflow-x: scroll;
}
bpageblock .detailList table td, .bPageBlock .detailList table th {
white-space:nowrap;
border-style:solid;
border-width:1px;
border-color:#E3DEB8;
color:blue;
font-weight:300;
text-decoration:underline;
}

.th {
	white-space: nowrap;
	
}
th {
font-weight:bold;
text-align:left;
white-space:nowrap;
text-decoration:underline;
color:blue;
}
table.tablesorter {
	font-family:'Verdana','Geneva',sans-serif;
	background-color: #CDCDCD;
	font-size: 8pt;
	width: 100%;
	text-align: left;
}
table.tablesorter thead tr th, table.tablesorter tfoot tr th {
	background-color: #e6EEEE;
	border: 1px solid #FFF;
	font-size: 8pt;
	padding: 4px;
}
table.tablesorter thead tr .header {
	background-image: url(bg.gif);
	background-repeat: no-repeat;
	background-position: center right;
	cursor: pointer;
}
table.tablesorter tbody td {
	color: #3D3D3D;
	padding: 4px;
	vertical-align: top;
		border: .5px solid #E3DEB8;
	font-size: 8pt;
}
table.tablesorter tbody tr.odd td {
	background-color:#F0F0F6;
}
table.tablesorter thead tr .headerSortUp {
	background-image: '/img/sort_asc_arrow.gif';
border: .5px solid #E3DEB8;
}
table.tablesorter thead tr .headerSortDown {
	background-image: url('/img/sort_desc_arrow.gif');
border: .5px solid #E3DEB8;
}

.tablescroll_head{
	border-width: 1px;
	border-spacing: 0px;
	border-style: outset;
	border-color: gray;
}


.tablescroll_head tr .headerSortUp {
	background-image: url('/img/sort_asc_arrow.gif');
	background-repeat:no-repeat;
	background-position:right top;
}

.tablescroll_head tr .headerSortDown {
	background-image: url('/img/sort_desc_arrow.gif');
	background-repeat:no-repeat;
	background-position:right top;;
}


table.tablesorter thead tr .headerSortDown, table.tablesorter thead tr .headerSortUp {
background-color: #E00747;
}

.tableStyle{

	border-width: 1px;
	border-spacing: 0px;
	border-style: outset;
	border-color: gray;
	border-collapse: collapse;
	
	background-color: white;
}

}
.odd{
background-color: white;
border-style:solid;
border-width:1px;
border-color:grey;
}

.even{
background-color: #E8E8E8;
border-style:solid;
border-width:1px;
border-color:grey;
}
.headerRow{
background-color: #FBEC5D;
}
 DIV.tableHolder {


WIDTH: 600px;
 POSITION: relative;
HEIGHT: 200px;
}

thead td{
Z-INDEX: 20;
POSITION: relative;
 TOP: expression(this.offsetParent.scrollTop-2);
HEIGHT: 20px;
TEXT-ALIGN: center
 }

 tfoot td{
 Z-INDEX: 20;
 POSITION: relative;
TOP: expression(this.offsetParent.clientHeight - this.offsetParent.scrollHeight + this.offsetParent.scrollTop); HEIGHT: 20px;
 TEXT-ALIGN: left;
 text-wrap: suppress
 }

.fixedLeft {
 z-index: 20;
font-weight: bold;
 LEFT: expression(this.offsetParent.scrollLeft-2);
POSITION: relative;
}

.fixedRight {
z-index: 20;
font-weight: bold;
LEFT: expression(this.offsetParent.clientWidth - this.offsetParent.scrollWidth + this.offsetParent.scrollLeft); POSITION: relative;
} 