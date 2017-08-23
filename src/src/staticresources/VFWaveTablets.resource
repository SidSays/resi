/* 	Author : Siddharth Sinha
	Description : This will style the Visualforce embedded in a lightning App for iPad and Android tablets
	Date : 8/5/2017
*/
       @media only screen 
       and (min-device-width: 768px) 
       and (max-device-width: 1024px) 
       and (orientation:landscape) { 
        .left-pane{
         width: 60% !important;
         display: inline-block;
         vertical-align: top;
        }
        .left-pane #dashboardviewer,.left-pane cDashboardViewer, .left-pane .waveAsset, .left-pane .embeddedSpinner{
            width:100% !important;
        }
        .left-pane .waveAsset{
            overflow: scroll;
            -webkit-overflow-scrolling: touch;
        }
       /* .left-pane .waveFrame{
           width: 1px;
            min-width: 100% !important;
            *width: 100% !important;
        } */
        .right-pane{
         width: 38% !important;
         display: inline-block;
         vertical-align: top;
        }
    }
       @media only screen 
       and (min-device-width: 800px) 
       and (max-device-width: 1280px) 
       and (orientation:landscape) { 
        .left-pane{
         width: 60% !important;
         display: inline-block;
         vertical-align: top;
        }
        .left-pane #dashboardviewer,.left-pane cDashboardViewer, .left-pane .waveAsset, .left-pane .embeddedSpinner{
            width:100% !important;
        }
        .left-pane .waveAsset{
            overflow: scroll;
            -webkit-overflow-scrolling: touch;
        }
       /* .left-pane .waveFrame{
           width: 1px;
            min-width: 100% !important;
            *width: 100% !important;
        } */
        .right-pane{
         width: 38% !important;
         display: inline-block;
         vertical-align: top;
        }
    }	