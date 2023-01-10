local addonName = 'Net Hull Sync'

if (SERVER) then

    util.AddNetworkString( addonName )

    local net_WriteEntity = net.WriteEntity
    local net_WriteVector = net.WriteVector
    local net_Broadcast = net.Broadcast
    local net_WriteUInt = net.WriteUInt
    local net_Start = net.Start
    local isvector = isvector
    local assert = assert
    local type = type

    local PLAYER = FindMetaTable( 'Player' )

    local setHullDuck = PLAYER.SetHullDuck
    function PLAYER:SetHullDuck( mins, maxs )
        assert( isvector( mins ), 'bad argument #1 to \'SetHullDuck\' (vector expected, got ' .. type( mins ) .. ')' )
        assert( isvector( maxs ), 'bad argument #2 to \'SetHullDuck\' (vector expected, got ' .. type( maxs ) .. ')' )

        if (mins[3] > 0) then return end
        if (maxs[3] <= 0) then return end

        net_Start( addonName )
            net_WriteEntity( self )
            net_WriteUInt( 0, 1 )
            net_WriteVector( mins )
            net_WriteVector( maxs )
        net_Broadcast()

        setHullDuck( self, mins, maxs )
    end

    local setHull = PLAYER.SetHull
    function PLAYER:SetHull( mins, maxs )
        assert( isvector( mins ), 'bad argument #1 to \'SetHullDuck\' (vector expected, got ' .. type( mins ) .. ')' )
        assert( isvector( maxs ), 'bad argument #2 to \'SetHullDuck\' (vector expected, got ' .. type( maxs ) .. ')' )

        if (mins[3] > 0) then return end
        if (maxs[3] <= 0) then return end

        net_Start( addonName )
            net_WriteEntity( self )
            net_WriteUInt( 1, 1 )
            net_WriteVector( mins )
            net_WriteVector( maxs )
        net_Broadcast()

        setHull( self, mins, maxs )
    end
end

if (CLIENT) then

    local net_ReadVector = net.ReadVector
    local net_ReadEntity = net.ReadEntity
    local net_ReadBool = net.ReadBool
    local IsValid = IsValid

    net.Receive(addonName, function()
        local ply = net_ReadEntity()
        if IsValid( ply ) and ply:IsPlayer() then
            if net_ReadBool() then
                ply:SetHull( net_ReadVector(), net_ReadVector() )
            else
                ply:SetHullDuck( net_ReadVector(), net_ReadVector() )
            end
        end
    end)

end