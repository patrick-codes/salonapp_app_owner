part of 'location_bloc.dart';

sealed class LocationEvent {}

class CheckLocationServices extends LocationEvent {}

class RequestLocationPermission extends LocationEvent {}

class LoadLocationEvent extends LocationEvent {}
