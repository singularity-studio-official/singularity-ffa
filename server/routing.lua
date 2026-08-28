function FFA.SetPlayerRouting(src, bucketId)
    SetPlayerRoutingBucket(src, bucketId)
end

function FFA.ResetPlayerRouting(src)
    -- Typically 0 is the default routing bucket for RP world
    SetPlayerRoutingBucket(src, 0)
end
