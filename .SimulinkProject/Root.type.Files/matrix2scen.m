function [drScn] = matrix2scen(roadMatrix, actorMatrix)
    
    %Route pieces to their respective build functions 
    drScn = drivingScenario();
    drScn.StopTime = inf;

    [drScn, pieces] = matrix2road2(drScn, roadMatrix);

    [actors, egoCar] = matrix2actr(drScn, actorMatrix, pieces);

    hFigure = figure;
    hFigure.Position(3) = 900;

    hPanel1 = uipanel(hFigure,'Units','Normalized','Position',[0 1/4 1/2 3/4],'Title','Scenario Plot');
    hPanel2 = uipanel(hFigure,'Units','Normalized','Position',[0 0 1/2 1/4],'Title','Chase Plot');
    hPanel3 = uipanel(hFigure,'Units','Normalized','Position',[1/2 0 1/2 1],'Title','Bird''s-Eye Plot');
    
    hAxes1 = axes('Parent',hPanel1);
    hAxes2 = axes('Parent',hPanel2);
    hAxes3 = axes('Parent',hPanel3);

    plot(drScn, 'Parent', hAxes1, 'Waypoints', 'off', 'Centerline','off');

    chasePlot(egoCar, 'Parent', hAxes2,'Centerline','off');

    bepPlot = birdsEyePlot('Parent', hAxes3,'XLim',[-50 50],'YLim',[-40 40]);
    outlineplotter = outlinePlotter(bepPlot);
    laneplotter = laneBoundaryPlotter(bepPlot);
    legend('off')
    

    while advance(drScn)
        rb = roadBoundaries(egoCar);
        [position,yaw,length,width,originOffset,color] = targetOutlines(egoCar);    
        plotLaneBoundary(laneplotter,rb)
        plotOutline(outlineplotter,position,yaw,length,width, ...
                    'OriginOffset',originOffset,'Color',color)
        pause(0.001)
    end

end