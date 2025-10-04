#include <iostream>
#include <string>

using namespace std; 

struct students{
    string name;
    string email; 
    //string username; I'm not sure what username we're supposed to use here, or how I would find that info
    string experiment;
    string hobby;
};

void print_info(students &info) {
    cout << "******** Student Info ********" << endl;
    cout << "For " << info.name << ", their info is: " << endl;
    cout << "email: " << info.email << endl; 
    cout << "experiment: " << info.experiment << endl;
    cout << "hobby: " << info.hobby << endl;
}

int main() {
    // There are 13 students this semester
    students kyla;
    students taylor;
    students kayleigh;
    students elias;
    students jenna; 
    students roy; 
    students justin;
    students max; 
    students dai_jon; 
    students julianne; 
    students daniel; 
    students walker; 
    students mark; 
    std::vector<string> student_structs = {"kyla","taylor","kayleigh","elias","jenna","roy","justin","max","dai_jon","julianna","daniel","walker","mark"};

    // Adding names
    kyla.name = "Kyla";
    taylor.name = "Taylor";
    kayleigh.name = "Kayleigh";
    elias.name = "Elias";
    jenna.name = "Jenna";
    roy.name = "Roy";
    justin.name = "Justin";
    max.name = "Max";
    dai_jon.name = "Dai Jon";
    julianne.name = "Julianna";
    daniel.name = "Daniel";
    walker.name = "Walker";
    mark.name = "Mark";

    // Adding emails
    kyla.email = "kmartine24@wisc.edu";
    taylor.email = "tsussmane@wisc.edu";
    kayleigh.email = "kexcell@wisc.edu";
    elias.email = "emettner@wisc.edu";
    jenna.email = "jroderick2@wisc.edu";
    roy.email = "rfcruz@wisc.edu";
    justin.email = "justin.marquez@wisc.edu";
    max.email = "max.zhao@princeton.edu";
    dai_jon.email = "daijonjames@umass.edu";
    julianne.email = "jstarzee@umass.edu";
    daniel.email = "dhumphreys@umass.edu";
    walker.email = "wsundquist@umass.edu";
    mark.email = "mmurdy@umass.edu";

    // Adding experiments
    kyla.experiment = "CMS";
    taylor.experiment = "CMS";
    kayleigh.experiment = "Rubin";
    elias.experiment = "CMS";
    jenna.experiment = "CMS";
    roy.experiment = "CMS";
    justin.experiment = "CMS";
    max.experiment = "CMS";
    dai_jon.experiment = "ATLAS";
    julianne.experiment = "ATLAS";
    daniel.experiment = "ATLAS";
    walker.experiment = "ATLAS";
    mark.experiment = "ATLAS";
    
    // Adding Hobbies
    kyla.hobby = "Dogs";
    taylor.hobby = "Reading";
    kayleigh.hobby = "Reading";
    elias.hobby = "Gluten-Free Cooking";
    jenna.hobby = "Crocheting";
    roy.hobby = "Video Games";
    justin.hobby = "Video Games";
    max.hobby = "Clarinet";
    dai_jon.hobby = "N/A";
    julianne.hobby = "Reading";
    daniel.hobby = "Hiking";
    walker.hobby = "Backpacking";
    mark.hobby = "N/A";

    print_info(kyla);
    print_info(taylor);
    print_info(kayleigh);
    print_info(elias);
    print_info(jenna);
    print_info(roy);
    print_info(justin);
    print_info(max);
    print_info(dai_jon);
    print_info(julianne);
    print_info(daniel);
    print_info(walker);
    print_info(mark);
    return 0;
}












