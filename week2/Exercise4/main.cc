#include <stdio.h>
#include <iostream>
#include <vector>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "hh/t1.h"

#include <TMath.h>
#include <TFile.h>
#include <TTree.h>
#include <TH1F.h>
#include <TCanvas.h> 
#include <TLorentzVector.h>



//------------------------------------------------------------------------------
// Particle Class
//
class Particle{

	public:
	Particle();
	// FIXME : Create an additional constructor that takes 4 arguments --> the 4-momentum
	Particle(double, double, double, double);
	double   pt, eta, phi, E, m, p[4];
	void     p4(double, double, double, double);
	void     print();
	void     setMass(double);
	double   sintheta();
};

class Lepton : public Particle{
	public:
	Lepton();
	int charge; 
	void setCharge(int);
	void print();
};

class Jet : public Particle{
	public:
	Jet();
	int hadronFlavor;
	void setHadronFlavor(int);
	void print();
};

//------------------------------------------------------------------------------

//*****************************************************************************
//                                                                             *
//    MEMBERS functions of the Particle Class                                  *
//                                                                             *
//*****************************************************************************

//
//*** Default constructor ------------------------------------------------------
//
Particle::Particle(){
	pt = eta = phi = E = m = 0.0;
	p[0] = p[1] = p[2] = p[3] = 0.0;
}

//*** Additional constructor ------------------------------------------------------
Particle::Particle(double p0, double p1, double p2, double p3){ 
	//FIXME
	pt = eta = phi = E = m = 0.0;
	p[0] = p0; 
	p[1] = p1;
	p[2] = p2;
	p[3] = p3;
}

Lepton::Lepton(){
	pt = eta = phi = E = m = 0.0;
	p[0] = p[1] = p[2] = p[3] = 0.0;
	charge = 0;
}

Jet::Jet(){
	pt = eta = phi = E = m = 0.0;
	p[0] = p[1] = p[2] = p[3] = 0.0;
	hadronFlavor = 0;
}
//
//*** Members  ------------------------------------------------------
//
double Particle::sintheta(){

	//FIXME
	double theta = 2*std::atan(std::exp(-eta));
	return std::sin(theta);
}

void Particle::p4(double pT, double Eta, double Phi, double energy){

	//FIXME
	pt = pT;
	eta = Eta;
	phi = Phi;
	E = energy;
}

void Particle::setMass(double mass)
{
	// FIXME
	m = mass;
}

void Lepton::setCharge(int chrge) {
	charge = chrge;
}

void Jet::setHadronFlavor(int flvr){
	hadronFlavor = flvr;
}
//
//*** Prints 4-vector ----------------------------------------------------------
//
void Particle::print(){
	std::cout << std::endl;
	std::cout << "(" << p[0] <<",\t" << p[1] <<",\t"<< p[2] <<",\t"<< p[3] << ")" << "  " <<  sintheta() << std::endl;
	std::cout << "pT = " << pt << std::endl;
	std::cout << "eta = " << eta << std::endl;
	std::cout << "phi = " << phi << std::endl;
	std::cout << "Energy = " << E << std::endl;
	std::cout << "mass = " << m << std::endl;
	std::cout << "sin(theta) = " << sintheta() << std::endl;
}

void Lepton::print() {
	std::cout << "Lepton Info: ";
	Particle::print(); 
	std::cout << "Charge = " << charge << std::endl;
}

void Jet::print() {
	std::cout << "Jet Info: ";
	Particle::print();
	std::cout << "Hadron Flavor = " << hadronFlavor << std::endl;
}

int main() {
	
	/* ************* */
	/* Input Tree   */
	/* ************* */

	TFile *f      = new TFile("input.root","READ");
	TTree *t1 = (TTree*)(f->Get("t1"));

	// Read the variables from the ROOT tree branches
	t1->SetBranchAddress("nleps",&nleps);
	t1->SetBranchAddress("lepPt",&lepPt);
	t1->SetBranchAddress("lepEta",&lepEta);
	t1->SetBranchAddress("lepPhi",&lepPhi);
	t1->SetBranchAddress("lepE",&lepE);
	t1->SetBranchAddress("lepQ",&lepQ);
	
	t1->SetBranchAddress("njets",&njets);
	t1->SetBranchAddress("jetPt",&jetPt);
	t1->SetBranchAddress("jetEta",&jetEta);
	t1->SetBranchAddress("jetPhi",&jetPhi);
	t1->SetBranchAddress("jetE", &jetE);
	t1->SetBranchAddress("jetHadronFlavour",&jetHadronFlavour);

	// Total number of events in ROOT tree
	Long64_t nentries = t1->GetEntries();

	for (Long64_t jentry=0; jentry<100;jentry++)
 	{
		t1->GetEntry(jentry);
		std::cout<<"******** Event "<< jentry << " ********" << std::endl;	

		//FIX ME
		for (int il = 0; il < nleps; ++il) {
			// Call print function
			Lepton lep_var; 
			lep_var.p4(lepPt[il], lepEta[il], lepPhi[il], lepE[il]);
			lep_var.setCharge(lepQ[il]);
			lep_var.print();
			std::cout << std::endl;
		} // Loop over lepton events
		for (int ij = 0; ij < njets; ++ij) {
			// Call print function
			Jet jet_var; 
			jet_var.p4(jetPt[ij], jetEta[ij], jetPhi[ij], jetE[ij]);
			jet_var.setHadronFlavor(jetHadronFlavour[ij]);
			jet_var.print();
			std::cout << std::endl;
		} // Loop over jet events

	} // Loop over all events

  	return 0;
}
