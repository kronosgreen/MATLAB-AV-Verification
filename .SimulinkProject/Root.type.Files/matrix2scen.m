function [drScn] = matrix2scen(roadMatrix, actorMatrix)
    
    %Route pieces to their respective build functions 
    drScn = drivingScenario();
    drScn.StopTime = inf;

    [drScn, pieces] = matrix2road2(drScn, roadMatrix);
    
    [vehicles, egoCar] = matrix2actr(drScn, actorMatrix, pieces);

    poseRecord = record(drScn);
    poseRecord.ActorPoses(1).Position(1)

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

    egoCarBEP = birdsEyePlot('Parent',hAxes3,'XLimits',[-200 200],'YLimits',[-240 240]);
    fastTrackPlotter = trackPlotter(egoCarBEP,'MarkerEdgeColor','red','DisplayName','target','VelocityScaling',.5);
    egoTrackPlotter = trackPlotter(egoCarBEP,'MarkerEdgeColor','blue','DisplayName','ego','VelocityScaling',.5);
    egoLanePlotter = laneBoundaryPlotter(egoCarBEP);
    plotTrack(egoTrackPlotter, [0 0]);
    egoOutlinePlotter = outlinePlotter(egoCarBEP);

    while advance(drScn)
        %t = targetPoses(egoCar);
        %plotTrack(fastTrackPlotter, t.Position, t.Velocity);
        pause(0.001)
        %rbs = roadBoundaries(egoCar);
        %plotLaneBoundary(egoLanePlotter, rbs);
        %[position, yaw, length, width, originOffset, color] = targetOutlines(egoCar);
        %plotOutline(egoOutlinePlotter, position, yaw, length, width, 'OriginOffset', originOffset, 'Color', color);
    end

    disp(getCurrentJob);
    fid = fopen('matrixFile.txt', 'a');
    save('matrixFile.txt','roadMatrix','-ascii', '-append');
    fprintf(fid, '\n');
    save('matrixFile.txt','actorMatrix','-ascii', '-append');
    fprintf(fid, '\n\n');
    fclose(fid);

end