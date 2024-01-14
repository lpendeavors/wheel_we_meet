import * as mongoose from 'mongoose';

export const ContactSchema = new mongoose.Schema(
  {
    name: String,
    phone: String,
    email: String,
  },
  { _id: false },
);

ContactSchema.set('toJSON', {
  virtuals: true,
  versionKey: false,
});

export const ParkingPricesSchema = new mongoose.Schema(
  {
    monthly: Number,
    daily: Number,
    weekly: Number,
  },
  { _id: false },
);

ParkingPricesSchema.set('toJSON', {
  virtuals: true,
  versionKey: false,
});

export const PlaceSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: String,
    address: String,
    categories: [String],
    contact: [ContactSchema],
    amenities: [String],
    parkingSpaces: Number,
    showers: Number,
    scales: Boolean,
    fuelLanes: Number,
    paymentsAccepted: [String],
    serviceBays: Number,
    serviceRadius: Number,
    parkingTypes: [String],
    parkingPrices: ParkingPricesSchema,
    geocoded: Boolean,
    location: {
      type: {
        type: String,
        enum: ['Point'],
        required: true,
      },
      coordinates: {
        type: [Number],
        required: true,
      },
    },
  },
  { timestamps: true },
);

PlaceSchema.index({ location: '2dsphere' });

PlaceSchema.set('toJSON', {
  virtuals: true,
  versionKey: false,
  transform: function (doc, ret) {
    delete ret._id;
  },
});
