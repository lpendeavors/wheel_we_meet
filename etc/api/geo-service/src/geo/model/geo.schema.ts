import * as mongoose from 'mongoose';

export const GeoSchema = new mongoose.Schema({
  locationId: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
  location: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], required: true },
  },
});

GeoSchema.index({ location: '2dsphere' });
