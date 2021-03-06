debug = require("debug")("sm:analytics:idx_writer")

module.exports = class IdxWriter extends require("stream").Writable
    constructor: (@es,@log) ->
        super objectMode:true
        debug "IdxWriter init"

    _write: (batch,encoding,cb) ->
        debug "_write with batch of #{batch.length}"
        bulk = []

        for obj in batch
            bulk.push index:{_index:obj.index, _type:obj.type}
            bulk.push obj.body

        @es.bulk body:bulk, (err,resp) =>
            if err
                err_str = "Failed to bulk insert #{batch.length} rows: #{err}"
                @log.error err_str
                debug err_str
                return cb new Error(err_str)

            debug "Inserted #{batch.length} rows."
            @emit "bulk"
            cb()
